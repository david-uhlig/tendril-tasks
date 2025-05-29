# frozen_string_literal: true

module TendrilTasks
  # Display a badge with the project's title and color scheme.
  #
  # By default, the badge links to the project's detail page.
  # The color scheme is determined by the project's ID.
  #
  # Example usage:
  #   <%= render TendrilTasks::ProjectBadge.new(project) %>
  class ProjectBadge < TendrilTasks::Component
    attr_reader :has_link

    # @param project [Project] the project to be displayed
    # @param has_link [Boolean] whether the badge should link to the project or to the href
    # @param href [String] the URL to link to. When not provided, the project's detail page is linked.
    def initialize(project, has_link: true, href: nil)
      @project = project
      @tag = has_link ? :a : :span
      @has_link = has_link
      @href_arg = href
    end

    def before_render
      @href = (@href_arg || project_path(project)) if has_link
      @scheme = helpers.badge_scheme_by_id(project.id)
    end

    def call
      render Gustwave::Badge.new(project.title, scheme:, tag:, href:)
    end

    private

    attr_reader :project, :scheme, :tag, :href, :has_link
  end
end
