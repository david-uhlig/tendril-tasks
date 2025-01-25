# frozen_string_literal: true

module Footer
  class Link
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :title, :href

    validates :title, presence: true
    validates :href, presence: true

    def attributes
      {
        "title" => title,
        "href" => href
      }
    end
  end
end
