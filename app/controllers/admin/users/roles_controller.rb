module Admin
  module Users
    class RolesController < ApplicationController
      before_action :set_user, only: [ :update ]
      # TODO add authorization
      def update
        authorize! :update, :user_roles
        # Refuse to remove the last admin
        if params[:role] != "admin" &&
          @user.admin? &&
          User.where(role: :admin).count <= 1
          render :last_admin_error
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
