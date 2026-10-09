# frozen_string_literal: true

module Admin
  module Brand
    class NameController < AdminController
      def update
        Setting.transaction do
          Setting.brand_name = params[:name]
          Setting.display_brand_name = params[:display_name]
        end
      rescue ActiveRecord::RecordInvalid => error
        @errors = error.record.errors
        render status: :unprocessable_content
      end
    end
  end
end
