# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  renders_many :links, Navigation::LinkComponent
  renders_one :login_button, ->(**options) {
    type = options.delete(:type) || :submit
    ::ButtonComponent.new(type: type, **options)
  }
end
