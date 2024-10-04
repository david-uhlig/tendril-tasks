class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # TODO add in :rememberable functionality
  devise :database_authenticatable,
         :omniauthable,
         omniauth_providers: %i[rocketchat]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      # Although this app uses omniauth only, a password is generated
      # because it is required for devise features like :rememberable
      user.password = Devise.friendly_token[0, 20]
      # TODO add in name, avatar-url
    end
  end
end
