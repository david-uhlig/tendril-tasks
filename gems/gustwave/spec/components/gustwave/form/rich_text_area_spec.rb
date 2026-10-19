# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichTextArea, type: :component do
  def render_with_editor(component = described_class.new(toolbar_id: "my-toolbar"), &block)
    render_inline(component) do |rich_text|
      rich_text.with_editor { "<textarea id='editor'></textarea>".html_safe }
      block&.call(rich_text)
    end
  end

  it "renders the default toolbar without a toolbar slot" do
    render_with_editor

    expect(page).to have_css("lexxy-toolbar#my-toolbar")
  end

  it "renders the toolbar slot in place of the default toolbar" do
    render_with_editor do |rich_text|
      rich_text.with_toolbar { "<nav id='custom-toolbar'></nav>".html_safe }
    end

    expect(page).to have_css("nav#custom-toolbar")
    expect(page).to have_no_css("lexxy-toolbar")
  end

  it "renders the editor slot" do
    render_with_editor

    expect(page).to have_css("textarea#editor")
  end

  it "replaces the toolbar builder in a subclass with extend_slot" do
    subclass = stub_const("RichTextAreaWithBoxedToolbar", Class.new(described_class) {
      extend_slot :toolbar, ->(&block) { tag.div(block.call, id: "boxed") }
    })

    render_with_editor(subclass.new) do |rich_text|
      rich_text.with_toolbar { "<nav></nav>".html_safe }
    end

    expect(page).to have_css("div#boxed > nav")
  end

  context "with a form builder" do
    def form_builder
      ActionView::Helpers::FormBuilder.new(:article, nil, vc_test_controller.view_context, {})
    end

    it "renders the default editor from the form builder, linked to the toolbar" do
      render_inline(described_class.new(form_builder, :body, toolbar_id: "my-toolbar"))

      expect(page).to have_css("lexxy-toolbar#my-toolbar")
      expect(page).to have_css("[toolbar='my-toolbar'].lexxy-content")
    end

    it "generates a toolbar id that the default editor shares" do
      render_inline(described_class.new(form_builder, :body))

      toolbar_id = page.find("lexxy-toolbar")["id"]
      expect(toolbar_id).to start_with("toolbar-")
      expect(page).to have_css("[toolbar='#{toolbar_id}'].lexxy-content")
    end

    it "sticks the toolbar to the top by default" do
      render_inline(described_class.new(form_builder, :body))

      expect(page).to have_css("div[class~='group-hover:sticky']")
    end

    it "doesn't stick the toolbar with sticky_toolbar: false" do
      render_inline(described_class.new(form_builder, :body, sticky_toolbar: false))

      expect(page).not_to have_css("div[class~='group-hover:sticky']")
    end
  end
end
