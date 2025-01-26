# frozen_string_literal: true

module Admin
  module Footer
    class CopyrightController < ApplicationController
      def update
        Setting.footer_copyright = params[:copyright_notice]
        redirect_to edit_admin_footer_path, notice: t(".update.notice")
      end
    end
  end
end
