# frozen_string_literal: true

module Admin
  module Site
    class HeroImageController < AdminController
      def update
        @site = ::Site.find_or_create_instance
        render status: :unprocessable_content unless @site.update(hero_image_params)
      end

      def destroy
        @site = ::Site.find_or_create_instance
        @site.hero_image.purge
      end

      private

      def hero_image_params
        params.require(:site).permit(:hero_image)
      end
    end
  end
end
