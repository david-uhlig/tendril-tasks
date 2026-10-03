# frozen_string_literal: true

module TendrilTasks
  # Use ContactsPill to render a pill-shaped button that lists the contact
  # people's avatars and names and opens the modal with their details.
  #
  #   <%= render TendrilTasks::ContactsPill.new(@project.coordinators,
  #                                             modal_id: "project-contacts-#{@project.id}",
  #                                             class: "mb-7") %>
  #
  # @param coordinators [Enumerable<User>] the contact people to list.
  # @param modal_id [String] the id of the modal the pill opens.
  # @param options [Hash] HTML attributes passed to the button. Classes are
  #   merged with the pill's own, e.g. to change its margins.
  class ContactsPill < TendrilTasks::Component
    style :base,
          "inline-flex items-center max-w-full py-1 px-1 pe-4 text-sm text-gray-700 bg-gray-100 rounded-full dark:bg-gray-800 dark:text-white hover:bg-gray-200 dark:hover:bg-gray-700"

    def initialize(coordinators, modal_id:, **options)
      @coordinators = coordinators
      @modal_id = modal_id

      options.symbolize_keys!
      options[:class] = styles(base: true, custom: options.delete(:class))
      @options = options
    end
  end
end
