# frozen_string_literal: true

module Admin
  module Footer
    class CopyrightController < AdminController
      def update
        footer = ::Footer.find_or_create_instance

        if footer.update(copyright: params[:copyright_notice])
          redirect_to edit_admin_footer_path, notice: t(".update.notice")
        else
          @sitemap = ::Footer::Sitemap.load
          @copyright = params[:copyright_notice]
          flash.now[:alert] = footer.errors.map(&:message).to_sentence
          render "admin/footer/edit", status: :unprocessable_content
        end
      end
    end
  end
end
