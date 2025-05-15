# frozen_string_literal: true

class NavigationComponent < TendrilTasks::Component
  renders_many :links, Navigation::LinkComponent
  alias link with_link
end
