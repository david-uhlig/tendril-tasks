# frozen_string_literal: true

class BreadcrumbComponent < ApplicationComponent
  renders_many :sections, Breadcrumb::LinkComponent
  alias section with_section
end
