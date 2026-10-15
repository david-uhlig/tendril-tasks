require "rails_helper"

module Gustwave
  module Specs
    module ContentHelper
      class TextOrContent
        include Gustwave::ContentHelper

        def initialize(text = nil)
          @text = text
        end

        def content
          "text_as_content_block"
        end

        private
        attr_reader :text
      end
    end
  end
end

class TextOrContentWithSlotComponent < Gustwave::Component
  renders_one :title, ->(text) { "<h1>#{text}</h1>".html_safe }

  def initialize(text = nil)
    @text = text
  end

  def call
    safe_join([ text_or_content, title ].compact)
  end
end

RSpec.describe Gustwave::ContentHelper, type: :helper do
  describe "#text_or_content" do
    let(:component) { Gustwave::Specs::ContentHelper::TextOrContent.new("text_as_instance_variable") }

    it "returns the text argument when it is present" do
      expect(component.text_or_content(text: "text_as_argument")).to eq("text_as_argument")
    end

    it "returns the instance variable when the text parameter is not present" do
      expect(component.text_or_content).to eq("text_as_instance_variable")
    end

    it "returns the content block when the text parameter is not present and the instance variable is not present" do
      component = Gustwave::Specs::ContentHelper::TextOrContent.new
      expect(component.text_or_content).to eq("text_as_content_block")
    end
  end
end

RSpec.describe TextOrContentWithSlotComponent, type: :component do
  it "renders slots set in the block when text is given" do
    render_inline(described_class.new("text")) do |component|
      component.with_title "Title"
    end

    expect(rendered_content).to have_text("text")
    expect(rendered_content).to have_selector("h1", text: "Title")
  end
end
