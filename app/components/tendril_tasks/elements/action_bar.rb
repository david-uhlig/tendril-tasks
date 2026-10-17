# frozen_string_literal: true

module TendrilTasks
  module Elements
    class ActionBar < TendrilTasks::Component
      def initialize(element)
        @element = element
        @project =
          if element.is_a?(Task)
            element.project
          else
            element
          end
      end

      def render?
        can?(:update, @element) || can?(:create, Task) || can?(:create, Project)
      end

      def call
        tag.ul class: "grow text-center sm:text-end whitespace-nowrap mb-4 sm:mb-0 space-x-1" do
          concat edit_button
          concat add_task_button
          concat add_project_button
        end
      end

      private

      def edit_button
        return unless can?(:update, @element)

        href = @element.is_a?(Task) ?
                 edit_task_path(@element) : edit_project_path(@element)

        tag.li class: "inline-flex" do
          render Gustwave::Buttons::Default.new(tag: :a,
                                                href: href,
                                                color: :default,
                                                size: :sm) do |button|
            button.with_leading_visual_icon(:edit)
            tag.span t(".edit_button")
          end
        end
      end

      def add_task_button
        return unless can?(:create, Task)

        tag.li class: "inline-flex" do
          render Gustwave::Buttons::Default.new(tag: :a,
                                                href: new_task_from_preset_path(
                                                  project_id: @project.id,
                                                  coordinator_ids: @project.coordinator_ids.join("-")
                                                ),
                                                color: :default,
                                                size: :sm) do |button|
            button.with_leading_visual_icon(:plus)
            tag.span(t(".add_task_button"))
          end
        end
      end

      def add_project_button
        return unless can?(:create, Project)

        tag.li class: "inline-flex" do
          render Gustwave::Buttons::DefaultOutline.new(tag: :a,
                                                       href: new_project_path,
                                                       color: :default,
                                                       size: :sm) do |button|
            button.with_leading_visual_icon(:plus)
            tag.span(t(".add_project_button"))
          end
        end
      end
    end
  end
end
