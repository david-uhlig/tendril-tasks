# frozen_string_literal: true

require "rails_helper"
require "yard"

# Checks AGENTS.md's YARD rule: every public class, module, constant and
# method has a docstring, a @param per parameter and a @return. It leaves out
# what .yardopts hides (@api private, and ViewComponent's call and
# before_render), blocks, which take @yield, and constructors' @return.
RSpec.describe "YARD documentation" do
  hooks = %i[call before_render].freeze

  objects = Dir.chdir(Gustwave::Engine.root) do
    # As in .yardopts, so a class documented with only its @status counts as documented.
    YARD::Tags::Library.define_tag("Status", :status)
    YARD::Tags::Library.visible_tags |= [ :status ]
    YARD::Registry.clear
    YARD::Logger.instance.enter_level(Logger::ERROR) { YARD.parse(%w[app/**/*.rb lib/**/*.rb]) }
    YARD::Registry.all
  end

  private_api = ->(object) {
    object.is_a?(YARD::CodeObjects::Base) && !object.root? &&
      (object.tag(:api)&.text == "private" || object.has_tag?(:private) || private_api.(object.namespace))
  }
  documented = objects.reject do |object|
    private_api.(object) || object.visibility != :public ||
      (object.type == :method && hooks.include?(object.name))
  end
  methods = documented.select { |object| object.type == :method && !object.is_alias? && !object.is_attribute? }

  it "documents every public object" do
    undocumented = documented.select { |object| object.docstring.blank? }.map(&:path)

    expect(undocumented).to be_empty, "Add a docstring to:\n  #{undocumented.join("\n  ")}"
  end

  it "documents every parameter with @param" do
    missing = methods.filter_map do |method|
      names = method.parameters.reject { |name, _| name.start_with?("&") }.map { |name, _| name.delete("*:") }.reject(&:empty?)
      untagged = names - method.tags(:param).map(&:name)
      "#{method.path} (#{untagged.join(", ")})" if untagged.any?
    end

    expect(missing).to be_empty, "Add a @param for:\n  #{missing.join("\n  ")}"
  end

  it "documents every method's result with @return" do
    missing = methods.reject { |method| method.constructor? || method.has_tag?(:return) }.map(&:path)

    expect(missing).to be_empty, "Add a @return to:\n  #{missing.join("\n  ")}"
  end
end
