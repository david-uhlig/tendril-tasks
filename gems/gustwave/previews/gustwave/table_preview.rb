module Gustwave
  class TablePreview < ViewComponent::Preview
    SUPPLIES = [
      { item: "Drinking water", location: "Kitchen", category: "Food", packaged: "Yes", available: "Yes", amount: "10 l", weight: "10 kg" },
      { item: "Wheat flour", location: "Pantry", category: "Food", packaged: "Yes", available: "No", amount: "2 kg", weight: "2 kg" },
      { item: "Candles", location: "Basement", category: "Household", packaged: "No", available: "Yes", amount: "12", weight: "1 kg" },
      { item: "First aid kit", location: "Hallway", category: "Medical", packaged: "Yes", available: "Yes", amount: "1", weight: "800 g" },
      { item: "Blankets", location: "Attic", category: "Shelter", packaged: "No", available: "Yes", amount: "6", weight: "9 kg" },
      { item: "Batteries", location: "Garage", category: "Tools", packaged: "Yes", available: "No", amount: "24", weight: "600 g" },
      { item: "Rain ponchos", location: "Hallway", category: "Clothing", packaged: "Yes", available: "Yes", amount: "8", weight: "1 kg" },
      { item: "Work gloves", location: "Garage", category: "Clothing", packaged: "No", available: "Yes", amount: "10", weight: "2 kg" },
      { item: "Tarpaulins", location: "Basement", category: "Shelter", packaged: "Yes", available: "No", amount: "4", weight: "6 kg" },
      { item: "Hand soap", location: "Pantry", category: "Hygiene", packaged: "Yes", available: "Yes", amount: "15", weight: "3 kg" }
    ].freeze

    VOLUNTEERS = [
      { name: "Ana Costa", email: "ana@example.org", role: "Coordinator", online: true },
      { name: "Ben Okafor", email: "ben@example.org", role: "Driver", online: true },
      { name: "Chloe Martin", email: "chloe@example.org", role: "Medic", online: false },
      { name: "Daniel Weber", email: "daniel@example.org", role: "Cook", online: true },
      { name: "Elif Yilmaz", email: "elif@example.org", role: "Translator", online: false }
    ].freeze

    # Rows of text with a header.
    def default = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # Every other row has a different background, set on the rows.
    def striped_rows = render_with_template(locals: { rows: SUPPLIES.first(5) })

    # Every other column has a different background, set on the cells.
    def striped_columns = render_with_template(locals: { rows: SUPPLIES.first(5) })

    # A row changes its background under the pointer.
    def hover = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # Column headers with a link that sorts by that column.
    def sortable_head = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # A summary row in the +foot+ slot.
    def foot = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # A title and description in the +caption+ slot.
    def caption = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # No row borders and no head background.
    def borderless = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # A shadow and rounded corners on the wrapper.
    def shadow = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # Plain grid rows comparing what each option includes. Not a +Table+.
    def comparison; end

    # A coloured head and rows.
    def colors = render_with_template(locals: { rows: SUPPLIES.first(5) })

    # Coloured rows with every other one a shade lighter.
    def striped_rows_colors = render_with_template(locals: { rows: SUPPLIES.first(5) })

    # Coloured rows with every other column a shade lighter.
    def striped_columns_colors = render_with_template(locals: { rows: SUPPLIES.first(5) })

    # Coloured rows that change their shade under the pointer.
    def hover_colors = render_with_template(locals: { rows: SUPPLIES.first(5) })

    # Many columns that scroll sideways.
    def scroll = render_with_template(locals: { rows: SUPPLIES })

    # The search field waits for form components.
    def search = render_with_template(locals: { rows: SUPPLIES.first(6) })

    # The filter's radio buttons and the search field wait for form components.
    def filter = render_with_template(locals: { rows: SUPPLIES.first(6) })

    # With +Pagination+ below.
    def pagination = render_with_template(locals: { rows: SUPPLIES })

    # Rows with a checkbox each, to select them.
    def checkbox = render_with_template(locals: { rows: SUPPLIES.first(6) })

    # People with an avatar and a status. The search field waits for form components.
    def users = render_with_template(locals: { people: VOLUNTEERS })

    # Items with an image. The quantity fields wait for form components.
    def products = render_with_template(locals: { rows: SUPPLIES.first(3) })

    # Editing a person in a modal. The modal's fields wait for form components.
    def modal = render_with_template(locals: { people: VOLUNTEERS })
  end
end
