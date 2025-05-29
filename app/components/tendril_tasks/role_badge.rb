# frozen_string_literal: true

# Renders roles badges depending on the given users role.
class TendrilTasks::RoleBadge < TendrilTasks::Component
  mapping :role_to_scheme, {
    admin: :purple,
    editor: :default,
    user: :default
  }, fallback: :user

  def initialize(user, size: :sm, border: true, **options)
    @user = user
    @role = user.role.to_sym
    @config = configure_component(
      options,
      tag: :a,
      scheme: role_to_scheme_mapping(role),
      size:,
      border:
    )
  end

  def before_render
    @config[:href] ||= role_to_path
  end

  def call
    if user.admin?
      render Gustwave::Badge.new(t(".role.admin"), **config)
    elsif user.editor?
      render Gustwave::Badge.new(t(".role.editor"), **config)
    end
  end

  private

  attr_reader :user, :config, :role

  def role_to_path
    case role
    when :admin
      admin_index_path
    else
      profile_path
    end
  end
end
