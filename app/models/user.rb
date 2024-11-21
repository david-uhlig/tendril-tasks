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

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # TODO add in :rememberable functionality
  devise :database_authenticatable,
         :omniauthable,
         omniauth_providers: %i[rocketchat]

  scope :default, -> { all }
  scope :exclude, ->(users) { where.not(id: users) }
  scope :exclude_ids, ->(user_ids) { where.not(id: user_ids) }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      # TODO improve handling of the email argument at the rocketchat provider side
      user.email = auth.info.email || auth.extra.raw_info.emails.first.address
      # Although this app uses omniauth only, a password is generated
      # because it is required for devise features like :rememberable
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.username = auth.info.username
      user.avatar_url = auth.info.image
      # TODO refresh email, name, avatar-url etc. when they are updated at the omniauth provider
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
end
