# frozen_string_literal: true

# Renders roles badges depending on the given users role.
class TendrilTasks::RoleBadge < TendrilTasks::Component
  ROLE_COLORS = {
    admin: :purple,
    editor: :default,
    user: :default
  }.freeze

  # A bordered badge turns gray in dark mode, these keep their color.
  ROLE_DARK_COLORS = {
    admin: "dark:bg-purple-900 dark:text-purple-300",
    editor: "dark:bg-blue-900 dark:text-blue-300",
    user: "dark:bg-blue-900 dark:text-blue-300"
  }.freeze

  def initialize(user, size: :sm, border: true, **options)
    @user = user
    @role = user.role.to_sym
    @config = configure_html_attributes(
      options,
      tag: :a,
      color: ROLE_COLORS.fetch(role, :default),
      size:,
      border:,
      class: ROLE_DARK_COLORS.fetch(role, ROLE_DARK_COLORS[:user])
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
      admin_root_path
    else
      profile_path
    end
  end
end
