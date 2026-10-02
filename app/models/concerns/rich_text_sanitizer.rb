# frozen_string_literal: true

module RichTextSanitizer
  extend ActiveSupport::Concern

  class_methods do
    # Saves a sanitized plain text version of the rich text attribute to the
    # specified plain text attribute. Automatically runs before save.
    #
    # This method is useful when you want to store a plain text version for
    # full-text search or preview purposes. Example:
    #
    #   class Message < ActiveRecord::Base
    #     include RichTextSanitizer
    #
    #     has_rich_text :content
    #     has_sanitized_plain_text :content_plain_text, :content
    #   end
    #
    #   message = Message.create!(content: "<h2>Funny times!</h2>Come to my birthday party!")
    #   message.content_plain_text # => "Funny times!\n\nCome to my birthday party!"
    def has_sanitized_plain_text(name, rich_text_attr)
      before_save -> { store_sanitized_plain_text(rich_text_attr, name) }
    end
  end

  private

  def store_sanitized_plain_text(rich_text_attr, plain_text_attr)
    unless respond_to?(plain_text_attr) && respond_to?("#{plain_text_attr}=")
      Rails.logger.warn "RichTextSanitizer: #{self.class.name} does not have a #{plain_text_attr} attribute."
      return
    end

    rich_text = send(rich_text_attr)&.body&.to_html
    processed_text = sanitize_plain_text(rich_text)
    send("#{plain_text_attr}=", processed_text)
  end

  def sanitize_plain_text(rich_text)
    return nil if rich_text.nil?
    return "" if rich_text.blank?

    # Convert headings (h2-h6) to h1, because ActionText::Content#to_plain_text
    # only converts h1 to plain text with line breaks.
    # Strip action-text-attachment tags.
    text = rich_text.gsub(/<h[2-6]>(.*?)<\/h[2-6]>/i, '<h1>\1</h1>')
                    .gsub(/<action-text-attachment\b[^>]*>.*?<\/action-text-attachment>/mi, "")

    plain_text = ActionText::Content.new(flatten_tables(text)).to_plain_text.strip
    ActionText::ContentHelper.sanitizer.sanitize(plain_text)
  end

  # Replaces each table with a paragraph per row, because
  # ActionText::Content#to_plain_text joins the text of all cells without
  # separators.
  def flatten_tables(html)
    return html unless html.match?(/<table\b/i)

    fragment = Nokogiri::HTML5.fragment(html)
    fragment.css("table").each do |table|
      rows = table.css("tr").map do |row|
        cells = row.css("th, td").map { |cell| cell.text.squish }.compact_blank
        "<p>#{ERB::Util.html_escape(cells.join(" "))}</p>"
      end
      table.replace(Nokogiri::HTML5.fragment(rows.join))
    end
    fragment.to_html
  end
end
