module Admin
  module Users
    class RolesController < ApplicationController
      before_action :set_user, only: [ :update ]

      def index
        authorize! :show, :admin_settings
        @users = User.order(role: :desc, name: :asc)
      end

      def update
        authorize! :update, :user_roles

        # Refuse to remove the last admin
        if params[:role] != "admin" &&
          @user.admin? &&
          User.where(role: :admin).count <= 1
          render :last_admin_error
          return
        end

        # Refuse to change permissions on current_user
        if @user == current_user
          render :cannot_change_current_user
          return
        end

        @user.role = params[:role]
        @user.save
      end

      private

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
