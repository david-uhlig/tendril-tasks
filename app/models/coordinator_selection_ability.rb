# frozen_string_literal: true

class CoordinatorSelectionAbility
  include CanCan::Ability

  def initialize(user)
    return unless user.present?
    return unless user.coordinator? || user.admin? || user.editor?

    # Can find and assign other users in the coordinator search modal.
    can :read, :coordinator_search_results
    can :assign, :coordinator_selections
  end
end
