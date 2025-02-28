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
    # @param has_link [Boolean] whether the badge should have a link
    # @param href [String] the URL to link to. When not provided, the project's detail page is linked.
    def initialize(project, has_link: true, href: nil)
      @project = project
      @has_link = has_link
      @href = href
    end

    def call
      scheme = helpers.badge_scheme_by_id(@project.id)
      badge_link_if has_link do
        render Gustwave::Badge.new(@project.title, scheme: scheme)
      end
    end

    private

    def badge_link_if(condition, &block)
      url = @href.presence || project_path(@project)
      optional_link_to_if(condition, url, &block)
    end
  end
end
