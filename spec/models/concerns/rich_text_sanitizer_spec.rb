# spec/models/concerns/rich_text_sanitizer_spec.rb

require "rails_helper"

RSpec.describe RichTextSanitizer, type: :concern do
  before do
    # Define a test model to include the concern
    stub_const("TestModel", Class.new(ActiveRecord::Base) do
      self.table_name = "test_models"
      include RichTextSanitizer

      has_rich_text :content
      has_sanitized_plain_text :content_plain_text, :content
    end)

    # Create the test table
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :test_models, force: true do |t|
          t.text :content_plain_text
          t.timestamps
        end
      end
    end
  end

  let(:test_model) { TestModel.new(content: content) }

  describe "#store_sanitized_plain_text" do
    context "when content contains HTML tags" do
      let(:content) { "<h2>Funny times!</h2>Come to my birthday party!" }

      it "stores a sanitized plain text version of the content" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("Funny times!\n\nCome to my birthday party!")
      end
    end

    context "when content contains action-text-attachment tags" do
      let(:content) { "<action-text-attachment sgid='123'>Attachment</action-text-attachment>" }

      it "removes action-text-attachment tags and their contents" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("")
      end
    end

    context "when content contains paragraphs" do
      let(:content) { "<h2>Agenda</h2><p>First paragraph</p><p>Second paragraph</p>" }

      it "separates the paragraphs with blank lines" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("Agenda\n\nFirst paragraph\n\nSecond paragraph")
      end
    end

    context "when content contains a table" do
      let(:content) do
        "<p>Before</p><table><tbody><tr><th>Name</th><th>Value</th></tr>" \
          "<tr><td><p>Water</p></td><td>1</td></tr></tbody></table><p>After</p>"
      end

      it "stores each row as a paragraph with the cells separated by spaces" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("Before\n\nName Value\n\nWater 1\n\nAfter")
      end
    end

    context "when content contains highlighted text" do
      let(:content) { "<p>Some <mark style=\"color: var(--highlight-3);\">colored</mark> text</p>" }

      it "stores the text without the highlight" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("Some colored text")
      end
    end

    context "when content is blank" do
      let(:content) { "" }

      it "stores nil as the sanitized plain text" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("")
      end
    end

    context "when content contains line breaks" do
      let(:content) { "First line\nSecond line" }

      it "preserves the line breaks in the sanitized plain text" do
        test_model.save!
        expect(test_model.content_plain_text).to eq("First line\nSecond line")
      end
    end
  end
end
