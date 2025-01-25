# frozen_string_literal: true

module Footer
  class Category
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :title, :links

    validates :title, presence: true
    validates :links, presence: true
    validate :links_valid?

    def initialize(attributes = {})
      super

      @links = attributes.present? ?
                 attributes.fetch("links", []).map { Footer::Link.new(it) } : []
    end

    def attributes
      {
        "title" => title,
        "links" => links.map(&:attributes)
      }
    end

    private

    def links_valid?
      links.all?(&:valid?).tap do |all_links_valid|
        next if all_links_valid
        # Collect errors if there are invalid links
        links.each { |link| errors.merge!(link.errors) unless link.valid? }
      end
    end
  end
end
