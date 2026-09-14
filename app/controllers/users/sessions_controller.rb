# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def destroy
      if expire_all_remember_me_tokens?
        User.transaction do
          current_user.expire_all_sessions!
          current_user.expire_all_remember_me!
        end
      end

      super
    end

    private

    def expire_all_remember_me_tokens?
      ActiveModel::Type::Boolean.new.cast(params.dig(:expire_all_remember_me_tokens))
    end
  end
end
