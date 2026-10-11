# frozen_string_literal: true

module Admin
  module Site
    class IdentityController < AdminController
      def update
        @site = ::Site.find_or_create_instance
        render status: :unprocessable_content unless @site.update(identity_params)
      end

      private

      def identity_params
        params.require(:site).permit(:name, :tagline)
      end
    end
  end
end
