# frozen_string_literal: true

module Admin
  class BrandController < AdminController
    def edit
      @brand = ::Brand.new
    end
  end
end
