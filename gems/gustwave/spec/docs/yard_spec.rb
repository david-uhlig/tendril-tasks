# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "yard"

# Every object the API docs show has a docstring, and every public method
# documents its parameters and return value. The docs show what .yardopts
# selects. See "Enforcement" in docs/design.md.
RSpec.describe "YARD docs" do
  rule = "docs/design.md#enforcement"

  before(:all) do
    Dir.chdir(File.expand_path("../..", __dir__)) do
      @warnings = StringIO.new
      original_io = log.io
      log.io = @warnings
      YARD::Registry.clear
      yardoc = YARD::CLI::Yardoc.new
      yardoc.parse_arguments
      YARD.parse(yardoc.files, yardoc.excluded)
      @objects = yardoc.options.verifier.run(YARD::Registry.all.reject(&:root?))
    ensure
      log.io = original_io
    end
  end

  after(:all) { YARD::Registry.clear }

  # Lists each gap under its file, so a fix can go file by file.
  def report(gaps)
    gaps.group_by(&:first).sort.map { |file, entries| "#{file}\n#{entries.map { |_, gap| "  #{gap}" }.join("\n")}" }.join("\n")
  end

  def public_methods_of(objects)
    objects.select { |object| object.type == :method && object.visibility == :public }
  end

  def parameter_names(method)
    method.parameters.filter_map do |name, _default|
      next if name.start_with?("&")

      name.delete_prefix("**").delete_prefix("*").delete_suffix(":")
    end
  end

  it "parses without warnings" do
    expect(@warnings.string).to be_empty, "Fix these YARD warnings, see #{rule}:\n#{@warnings.string}"
  end

  it "documents every class, module, constant and method" do
    gaps = @objects.select { |object| object.docstring.blank? && !object.tag(:return) }
      .map { |object| [ object.file, "#{object.path}: add a docstring" ] }

    expect(gaps).to be_empty, "Document these, see #{rule}:\n#{report(gaps)}"
  end

  it "documents every parameter of a public method" do
    gaps = public_methods_of(@objects).filter_map do |method|
      missing = parameter_names(method) - method.tags(:param).map(&:name)
      [ method.file, "#{method.path}: add @param #{missing.join(", ")}" ] if missing.any?
    end

    expect(gaps).to be_empty, "Add these @param tags, see #{rule}:\n#{report(gaps)}"
  end

  it "documents the return value of every public method" do
    gaps = public_methods_of(@objects)
      .reject { |method| method.constructor? || method.is_attribute? || method.tag(:return) }
      .map { |method| [ method.file, "#{method.path}: add @return" ] }

    expect(gaps).to be_empty, "Add these @return tags, see #{rule}:\n#{report(gaps)}"
  end
end
