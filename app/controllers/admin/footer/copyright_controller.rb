# frozen_string_literal: true

module Admin
  module Footer
    class CopyrightController < AdminController
      def update
        Setting.footer_copyright = params[:copyright_notice]
        redirect_to edit_admin_footer_path, notice: t(".update.notice")
      rescue ActiveRecord::RecordInvalid => error
        @sitemap = ::Footer::Sitemap.load
        @copyright = params[:copyright_notice]
        flash.now[:alert] = error.record.errors.map(&:message).to_sentence
        render "admin/footer/edit", status: :unprocessable_content
      end
    end
  end
end
