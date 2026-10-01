module Admin
  module Users
    class RolesController < AdminController
      before_action :set_user, only: [ :update ]

      def index
        @users = User.order(role: :desc, name: :asc)
      end

      def update
        # Refuse to change permissions on current_user
        if @user == current_user
          render :cannot_change_current_user
          return
        end

        role = params[:role].to_s
        return head :unprocessable_content unless User.roles.key?(role)

        @user.update!(role: role)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
