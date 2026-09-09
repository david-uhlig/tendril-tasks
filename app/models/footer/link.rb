# frozen_string_literal: true

module Footer
  class Link
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_reader :title, :href

    validates :title, presence: true
    validates :href, presence: true
    validate :href_must_be_trustable

    def title=(value)
      @title = value&.strip
    end

    def href=(value)
      @href = normalize_href(value)
    end

    # Returns the attribute hash for serialization.
    def attributes
      {
        "title" => title,
        "href" => href
      }
    end

    private

    def normalize_href(value)
      value = value&.strip
      uri = URI.parse(value).normalize

      if uri.scheme
        uri.to_s
      elsif value.start_with?("/")
        value
      else
        "https://#{value}"
      end
    rescue URI::InvalidURIError
      nil
    end

    def href_trustable?
      uri = URI.parse(href).normalize
      if uri.scheme
        %w[http https].include?(uri.scheme) && uri.host.present? && uri.userinfo.nil?
      else
        href.start_with?("/") && !href.start_with?("//") && !href.start_with?("/admin") && uri.host.nil?
      end
    end

    def href_must_be_trustable
      return if href.blank?

      errors.add(:href, :untrustable) unless href_trustable?
    end
  end
end
