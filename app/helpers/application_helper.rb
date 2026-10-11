module ApplicationHelper
  # Wraps the given block in a link if the condition is true. Otherwise, returns the block as is.
  #
  # @param condition [Boolean] whether the block should be wrapped in a link
  # @param url_or_options [String, Hash] the URL string or options hash for the link. Passed to +link_to+, equivalent to the +options+ parameter of +link_to+.
  # @param options [Hash] additional options for the link
  # @yield the block to be wrapped in a link
  # @return [String] the block wrapped in a link if the condition is true, otherwise the block as is
  def optional_link_to_if(condition, url_or_options, html_options = {}, &block)
    if condition
      link_to(url_or_options, html_options, &block)
    elsif block_given?
      capture(&block)
    else
      "" # Return empty string if no block is given
    end
  end

  # Returns the title of the document, e.g. for the browser tab: "Page - Site",
  # or "Site - Tagline" when the page sets no +:title+ of its own.
  #
  # @return [String] the title, safe to output as HTML
  def document_title
    site = Site.instance

    if content_for?(:title)
      t("layouts.application.page_title_html", page: content_for(:title), site: site.name)
    else
      AppConfig.title.presence ||
        t("layouts.application.site_title_html",
          site: site.name,
          tagline: site.tagline || t("layouts.application.default_tagline"))
    end
  end
end
