# frozen_string_literal: true

module Admin
  module Site
    class HomeTextController < AdminController
      def update
        @site = ::Site.find_or_create_instance
        render status: :unprocessable_content unless @site.update(home_text_params)
      end

      # Clears the texts, so the home page shows the default texts again.
      def destroy
        @site = ::Site.find_or_create_instance
        @site.update!(home_title: nil, home_title_highlight: nil, home_introduction: nil)
      end

      private

      def home_text_params
        params.require(:site).permit(:home_title, :home_title_highlight, :home_introduction)
      end
    end
  end
end
