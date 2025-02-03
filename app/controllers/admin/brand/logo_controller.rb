# frozen_string_literal: true

module Admin
  module Brand
    class LogoController < ApplicationController
      def update
        authorize! :update, :admin_settings

        Setting.brand_logo = params[:logo]
      end

      def destroy
        authorize! :destroy, :admin_settings

        Setting.brand_logo.purge
      end
    end
  end
end
