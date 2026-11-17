# frozen_string_literal: true

# Form controls that include Gustwave::Form::BoundControl: a bound control
# defaults to the +:error+ state while its attribute has errors (D17 in
# docs/design.md). Its own +validation+ wins, then the state of its field.
#
# @param slot [Symbol] the control's type in its field, e.g. +:input+
# @param field_class [Class] the field the control renders in
# @param id [String] a +format+ string of the ID of the element that gets +aria-invalid+, given the attribute, e.g. "task_%s"
# @param error_look [String, nil] a selector the element matches in the error state only, for a control with a look
# @param control_options [Hash] what the control needs besides the attribute and +form+, e.g. a radio's +value+
RSpec.shared_examples "a bound control defaulting to the error state" do |slot:, id: "task_%s", field_class: Gustwave::Form::Field,
                                                                           error_look: nil, control_options: {}|
  describe "the default validation state" do
    def record_with_errors_on(attribute, message = "is invalid")
      task.tap { |record| record.errors.add(attribute, message) }
    end

    define_method(:render_control) do |attribute, record, **options|
      render_inline(described_class.new(attribute, form: form_builder(record), **control_options, **options))
    end

    define_method(:control_element) do |attribute = :title|
      page.find("[id='#{format(id, attribute)}']")
    end

    define_method(:expect_error_state) do |attribute = :title|
      expect(control_element(attribute)["aria-invalid"]).to eq("true")
      expect(page).to have_css(error_look) if error_look
    end

    define_method(:expect_no_error_state) do |attribute = :title|
      expect(control_element(attribute)["aria-invalid"]).to be_nil
      expect(page).to have_no_css(error_look) if error_look
    end

    it "is :error while the bound attribute has errors" do
      render_control(:title, record_with_errors_on(:title))

      expect_error_state
    end

    it "is :none while the bound attribute has no errors" do
      render_control(:title, record_with_errors_on(:password))

      expect_no_error_state
    end

    it "lets the control's own validation win" do
      render_control(:title, record_with_errors_on(:title), validation: :none)
      expect_no_error_state

      render_control(:title, record_with_errors_on(:title), validation: :success)
      expect_no_error_state
    end

    it "lets the state of its field win" do
      render_inline(field_class.new(:title, form: form_builder(record_with_errors_on(:title)), validation: :none)) do |field|
        field.public_send(:"with_control_#{slot}", **control_options)
      end

      expect_no_error_state
    end

    it "is :error for an attribute bound through its field" do
      render_inline(field_class.new(:title, form: form_builder(record_with_errors_on(:title)))) do |field|
        field.public_send(:"with_control_#{slot}", **control_options)
      end

      expect_error_state
    end

    it "takes the errors of the association of a name_id attribute" do
      render_control(:project_id, record_with_errors_on(:project, "must exist"))

      expect_error_state(:project_id)
    end

    it "leaves an unbound control without errors alone" do
      render_inline(described_class.new(id: format(id, :title), name: "title", **control_options))

      expect_no_error_state
    end
  end
end
