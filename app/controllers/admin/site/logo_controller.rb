# frozen_string_literal: true

module Admin
  module Site
    class LogoController < AdminController
      def update
        @site = ::Site.find_or_create_instance
        render status: :unprocessable_content unless @site.update(logo_params)
      end

      def destroy
        ::Site.find_or_create_instance.logo.purge
      end

      private

      def logo_params
        params.require(:site).permit(:logo)
      end
    end
  end
end
