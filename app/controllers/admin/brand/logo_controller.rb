# frozen_string_literal: true

module Admin
  module Brand
    class LogoController < AdminController
      def update
        Setting.brand_logo = params[:logo]
      end

      def destroy
        Setting.brand_logo&.purge
      end
    end
  end
end
