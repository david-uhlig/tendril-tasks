# frozen_string_literal: true

class BreadcrumbComponent < ApplicationComponent
  renders_one :home_slot, ->(title = "Start", href: root_path, icon: :home) {
    Breadcrumb::LinkComponent.new(title, href: href, icon: icon)
  }
  alias home with_home_slot

  renders_many :sections, Breadcrumb::LinkComponent
  alias section with_section
end
