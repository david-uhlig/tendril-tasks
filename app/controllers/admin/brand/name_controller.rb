# frozen_string_literal: true

module Admin
  module Brand
    class NameController < AdminController
      def update
        Setting.brand_name = params[:name]
        Setting.display_brand_name = ActiveModel::Type::Boolean.new.cast(params[:display_name])
      end
    end
  end
end
