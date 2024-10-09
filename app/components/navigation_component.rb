# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  renders_one :logo, Navigation::LogoComponent
  renders_many :links, Navigation::LinkComponent
  renders_one :login_button, ButtonComponent
end
