# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  renders_many :links, Navigation::LinkComponent
  alias link with_link

  renders_one :login_button, ->(**options) {
    type = options.delete(:type) || :submit
    ::ButtonComponent.new(type: type, **options)
  }
end
