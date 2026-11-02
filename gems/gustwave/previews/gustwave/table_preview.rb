module Gustwave
  class TablePreview < ViewComponent::Preview
    def default
      render_with_template(locals: { rows: [ [ "Water", "10 l", "Kitchen" ], [ "Flour", "2 kg", "Pantry" ], [ "Candles", "12", "Basement" ] ] })
    end
  end
end
