module Gustwave
  class RichTextPreview < ViewComponent::Preview
    SAMPLE = <<~HTML
      <h1>Heading one</h1>
      <p>A paragraph with <strong>bold</strong>, <em>italic</em> and a <a href="#">link</a>.</p>
      <h2>Heading two</h2>
      <ul><li>First item</li><li>Second item</li></ul>
      <ol><li>Numbered item</li><li>Another numbered item</li></ol>
      <blockquote>A quote that stands out.</blockquote>
      <pre>preformatted code block</pre>
    HTML

    # Renders stored rich text the way Action Text does.
    def default
      render Gustwave::RichText.new(SAMPLE)
    end
  end
end
