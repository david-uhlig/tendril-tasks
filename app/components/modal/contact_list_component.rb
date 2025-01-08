# frozen_string_literal: true

module Modal
  class ContactListComponent < TendrilTasks::Component
    DEFAULT_CLASS = "my-4 space-y-3"

    def initialize(coordinators, **options)
      @coordinators = coordinators
      @options = build_options(options)
    end

    def call
      tag.ul **@options do
        @coordinators.each do |coordinator|
          concat render Modal::ContactItemComponent.new(coordinator)
        end
      end
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:class] = class_merge(
        DEFAULT_CLASS,
        options.delete(:class)
      )
      options
    end
  end
end
