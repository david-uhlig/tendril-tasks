# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # ----- Guest -----

    # ----- User -----
    return unless user.present?

    # Can read published projects with 1+ published tasks
    can :read, Project, {
      published_at: ..Time.zone.now,
      tasks: { published_at: ..Time.zone.now }
    }

    # Can show, update and destroy projects when they are coordinators
    can [ :show, :update, :destroy ], Project, {
      coordinators: { id: user.id }
    }

    # Can read published tasks from published projects
    can :read, Task, {
      published_at: ..Time.zone.now,
      project: { published_at: ..Time.zone.now }
    }

    # Can show, update and destroy tasks where they are coordinators
    can [ :show, :update, :destroy ], Task, {
      coordinators: { id: user.id }
    }

    can [ :update, :destroy ], User, { id: user.id }

    # ----- Editor -----
    return unless user.editor?

    # Can create new projects and tasks
    can [ :create ], [ Project, Task ]

    # ----- Admin -----
    nil unless user.admin?

    # Can assign user roles

    # Can delete user accounts
  end
end
