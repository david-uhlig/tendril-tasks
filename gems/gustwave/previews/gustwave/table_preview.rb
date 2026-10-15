module Gustwave
  class TablePreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/table/default
    def default
      render_with_template(locals: { rows: [ [ "Water", "10 l", "Kitchen" ], [ "Flour", "2 kg", "Pantry" ], [ "Candles", "12", "Basement" ] ] })
    end
  end
end
