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

  def self.from_omniauth(auth)
    # TODO refresh email, name, avatar-url etc. when they are updated at the omniauth provider
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email || auth.extra.raw_info.emails.first.address
      # Although this application uses only omniauth, a password is generated
      # because it is required for devise features such as :rememberable
      user.password = Devise.friendly_token[0, 20]
      # Real name
      user.name = auth.info.name
      user.username = auth.info.username
      # TODO We might need to store the etag, too
      user.avatar_url = auth.info.avatar.url
      user.role = determine_role(auth)
    end
  end

  def self.search(terms = nil)
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
  def self.determine_role(auth)
    return :user if User.where(role: :admin).count > 0
    return :admin if auth.roles&.include?("admin")

    :user
  end
end
