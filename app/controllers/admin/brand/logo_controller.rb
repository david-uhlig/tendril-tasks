# frozen_string_literal: true

module Admin
  module Brand
    class LogoController < AdminController
      def update
        @setting = Setting.save_brand_logo(logo_params.dig(:attachment))
        render status: :unprocessable_content if @setting.errors.any?
      end

      def destroy
        Setting.brand_logo&.purge
      end

      private

      def logo_params
        params.require(:setting).permit(:attachment)
      end
    end
  end
end
