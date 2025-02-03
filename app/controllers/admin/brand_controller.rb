# frozen_string_literal: true

module Admin
  class BrandController < ApplicationController
    # TODO add request specs

    def edit
      authorize! :update, :admin_settings

      @brand = ::Brand.new
    end
  end
end
