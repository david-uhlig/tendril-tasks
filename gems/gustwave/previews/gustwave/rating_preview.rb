module Gustwave
  class RatingPreview < ViewComponent::Preview
    # A score of 4 out of 5 stars, Flowbite's default rating.
    def default
      render Gustwave::Rating.new(4)
    end

    # The score as text after the stars: the score, "out of" and the maximum.
    def text
      render_with_template
    end

    # A single star with the score in bold, a dot, and a link to the reviews.
    def count
      render_with_template
    end

    # Small, medium and large stars, for a score of 4.
    def sizes
      render_with_template
    end

    # A rating with its score, the number of global ratings, and a Progress bar
    # per star count.
    def advanced
      render_with_template
    end

    # One customer's comment, with their picture, name, rating, title, text and votes.
    def comment
      render_with_template
    end

    # An overall score with its verdict and review count, broken down by
    # category with a Progress bar. It has no stars.
    def score
      render_with_template
    end

    # A guest review in a three-column grid: the guest and their stay, then the
    # review with its 8.7 score badge and helpful votes. It has no stars;
    # it's composed from Avatar, Heading, Badge, Link and Icon.
    def review
      render_with_template
    end

    # Change the score, the number of stars and the size.
    # @param value [Float] number
    # @param max [Integer] number
    # @param size select { choices: [sm, md, lg] }
    def playground(value: 4.95, max: 5, size: :sm)
      render Gustwave::Rating.new(value, max:, size:)
    end
  end
end
