# frozen_string_literal: true

module Admin
  module Brand
    class NameController < ApplicationController
      def update
        authorize! :update, :admin_settings

        Setting.brand_name = params[:name]
        Setting.display_brand_name = ActiveModel::Type::Boolean.new.cast(params[:display_name])
      end
    end
  end
end
