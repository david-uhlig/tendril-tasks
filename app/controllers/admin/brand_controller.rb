# frozen_string_literal: true

module Admin
  class BrandController < AdminController
    def edit
      @brand = ::Brand.new
      @setting = Setting.new
    end
  end
end
