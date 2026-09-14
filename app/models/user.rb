class User < ApplicationRecord
  has_and_belongs_to_many :projects_as_coordinator,
                          class_name: "Project",
                          join_table: "project_coordinators",
                          association_foreign_key: "project_id",
                          foreign_key: "user_id"

  has_and_belongs_to_many :tasks_as_coordinator,
                          class_name: "Task",
                          join_table: "task_coordinators",
                          association_foreign_key: "task_id",
                          foreign_key: "user_id"

  has_many :task_applications, dependent: :destroy
  has_many :tasks_applied, through: :task_applications, source: :task

  enum :role, { user: 0, editor: 1, admin: 99 }

  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :omniauthable,
         :rememberable,
         :timeoutable,
         omniauth_providers: %i[rocketchat]

  scope :default, -> { all }
  scope :exclude, ->(users) { where.not(id: users) }
  scope :exclude_ids, ->(user_ids) { where.not(id: user_ids) }

  class << self
    def from_omniauth(auth)
      # TODO refresh email, name, avatar-url etc. when they are updated at the omniauth provider
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        # Although this application uses only omniauth, a password is generated
        # because it is required for devise features such as :rememberable
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.dig(:info, :name)
        user.email = auth.dig(:info, :email)
        user.username = auth.dig(:info, :nickname)
        user.avatar_url = auth.dig(:info, :image)
        user.role = determine_role(auth)
      end
    end

    def search(terms = nil)
      return default unless terms.present?

      terms = terms.downcase
      users = User.arel_table

      terms = "%#{sanitize_sql_like(terms)}%"
      terms = terms.split.join("%") # Simple fuzzy search

      where(users[:name].matches(terms))
        .or(where(users[:username].matches(terms)))
    end

    private

    # Determines the role of a user based on the authentication data and the
    # current state of the database.
    #
    # If there are no users with the :admin role in the database, the first user
    # to log in with the "admin" role in the authentication data will be assigned
    # :admin. Otherwise, the user will be assigned the role of :user.
    #
    # @param auth [OmniAuth::AuthHash] The authentication hash containing user information.
    # @return [Symbol] The role of the user, either :user or :admin.
    def determine_role(auth)
      return :user if User.where(role: :admin).count > 0
      return :admin if auth.dig(:extra, :raw_info, :roles)&.include?("admin")

      :user
    end
  end

  def coordinator?
    projects_as_coordinator.exists? || tasks_as_coordinator.exists?
  end

  # Returns the salt for the user's session token.
  #
  # Extends Devise's `authenticatable_salt` with a session token. Change the
  # `session_token` attribute to invalidate the user's session. Use
  # `expire_all_sessions!` to expire all sessions of the user.
  def authenticatable_salt
    "#{super}#{session_token.presence}"
  end

  # Invalidates all session cookies on the next request.
  def expire_all_sessions!
    return unless persisted?

    update(session_token: SecureRandom.hex)
  end
end
