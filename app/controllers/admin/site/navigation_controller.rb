# frozen_string_literal: true

module Admin
  module Site
    class NavigationController < AdminController
      def update
        @site = ::Site.find_or_create_instance
        render status: :unprocessable_content unless @site.update(navigation_params)
      end

      private

      def navigation_params
        params.require(:site).permit(:navigation_label, :display_navigation_label)
      end
    end
  end
end
