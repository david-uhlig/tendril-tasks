# frozen_string_literal: true

class NavigationComponent < TendrilTasks::Component
  renders_many :links, Navigation::LinkComponent
  alias link with_link

  renders_one :login_button, ->(**options) {
    type = options.delete(:type) || :submit
    Gustwave::Button.new(type: type, **options)
  }
end
