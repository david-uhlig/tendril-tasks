# frozen_string_literal: true

module Admin
  module Footer
    class SitemapController < AdminController
      def update
        @sitemap = ::Footer::Sitemap.new(sitemap_params)
        unless @sitemap.save
          render "admin/footer/edit", status: :unprocessable_content
          nil
        end
      end

      def destroy
        @sitemap = ::Footer::Sitemap.new(Setting.footer_sitemap)
        @sitemap.destroy

        flash[:success] = t("admin.footer.sitemap.destroyed")
        redirect_to edit_admin_footer_path
      end

      private

      def sitemap_params
        discard_empty_links_and_categories(
          params.permit(categories: [ :title, links: [ :title, :href ] ])
        )
      end

      def discard_empty_links_and_categories(params)
        categories = params["categories"] || []
        categories.each do |category|
          next unless category["links"].present?

          category["links"].reject! do |link|
            link["href"].empty? && link["title"].empty?
          end
        end
        categories.reject! do |category|
          category["title"].empty? && (category["links"].nil? || category["links"].empty?)
        end
        # The form lists categories in the footer's left-to-right order, which
        # is the reverse of the stored order.
        params["categories"] = categories.reverse
        params
      end
    end
  end
end
