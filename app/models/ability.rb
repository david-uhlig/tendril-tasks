# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # ----- Guest -----
    can :read, Page

    # ----- User -----
    return unless user.present?

    # Can read published projects with 1+ published tasks
    can :read, Project, {
      published_at: ..Time.zone.now,
      tasks: { published_at: ..Time.zone.now }
    }

    # Can show, coordinate, update, and destroy projects when they are coordinators
    can [ :show, :coordinate, :update, :destroy ], Project, {
      coordinators: { id: user.id }
    }

    # Can read published tasks from published projects
    can :read, Task, {
      published_at: ..Time.zone.now,
      project: { published_at: ..Time.zone.now }
    }

    # Can show, coordinate, update and destroy tasks where they are coordinators
    can [ :show, :coordinate, :update, :destroy ], Task, {
      coordinators: { id: user.id }
    }

    can [ :update, :destroy ], User, { id: user.id }

    # ----- Editor -----
    return unless user.editor? || user.admin?

    can :manage, Project
    can :coordinate, Project
    can [ :create ], [ Project, Task ]

    # ----- Admin -----
    return unless user.admin?

    # Manage semi-static pages, e.g. imprint, privacy policy, terms of service.
    can :manage, Page
    can :manage, :admin_settings
    can :manage, :user_roles
  end
end
