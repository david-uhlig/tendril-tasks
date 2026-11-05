# frozen_string_literal: true

module Gustwave
  # Use Stepper to show the steps of a process, such as a checkout, and how far
  # the user has got. Add each step with +with_step+. A step is +:complete+ once
  # it's done, +:current+ while the user is on it, and +:upcoming+ otherwise (the
  # default). The current step's item gets +aria-current="step"+.
  #
  # Pick a style with +style+:
  #
  # * +:default+ (default): numbered steps in a row, joined by a line.
  # * +:progress+: icons in circles in a row, joined by a line. The step text is
  #   for screen readers only.
  # * +:detailed+: numbered steps with a description under each title.
  # * +:breadcrumb+: numbered steps in a bordered bar, with chevrons between them.
  # * +:vertical+: one box per step, stacked, colored by state.
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Stepper.new(aria: { label: "Checkout progress" }) do |stepper| %>
  #     <% stepper.with_step("Personal info", state: :complete) %>
  #     <% stepper.with_step("Account info", state: :current) %>
  #     <% stepper.with_step("Confirmation") %>
  #   <% end %>
  #
  # === Icons
  #
  # An icon replaces the step's number. In +:vertical+ it sits after the title
  # instead. Add it with +with_icon+ in the step's block:
  #
  #   <%= render Gustwave::Stepper.new(style: :progress, aria: { label: "Checkout progress" }) do |stepper| %>
  #     <% stepper.with_step("Personal info", state: :complete) { |step| step.with_icon(:check) } %>
  #     <% stepper.with_step("Account info", state: :current) { |step| step.with_icon(:profile_card, theme: :solid) } %>
  #     <% stepper.with_step("Confirmation") { |step| step.with_icon(:clipboard_check, theme: :solid) } %>
  #   <% end %>
  #
  # === Text in a block
  #
  # The step's text can be a block, e.g. to hide part of it on small screens:
  #
  #   <%= render Gustwave::Stepper.new(style: :breadcrumb) do |stepper| %>
  #     <% stepper.with_step(state: :current) do %>
  #       Personal <span class="hidden sm:inline-flex sm:ms-2">Info</span>
  #     <% end %>
  #     <% stepper.with_step("Review") %>
  #   <% end %>
  #
  # === Detailed
  #
  # Pass +description+ to add a line under each title. Only the +:detailed+ style
  # shows it:
  #
  #   <%= render Gustwave::Stepper.new(style: :detailed) do |stepper| %>
  #     <% stepper.with_step("User info", state: :current, description: "Step details here") %>
  #     <% stepper.with_step("Company info", description: "Step details here") %>
  #   <% end %>
  #
  # @param style [Symbol] +:default+ (default), +:progress+, +:detailed+, +:breadcrumb+ or +:vertical+.
  # @param options [Hash] HTML attributes for the +<ol>+ element.
  #
  # @status alpha
  class Stepper < Gustwave::Component
    variant :style, default: :default, values: {
      default: "flex items-center w-full text-sm font-medium text-center text-gray-500 dark:text-gray-400 sm:text-base",
      progress: "flex items-center w-full",
      detailed: "items-center w-full space-y-4 sm:flex sm:space-x-8 sm:space-y-0 rtl:space-x-reverse",
      breadcrumb: "flex items-center w-full p-3 space-x-2 text-sm font-medium text-center text-gray-500 bg-white border border-gray-200 rounded-lg shadow-xs dark:text-gray-400 sm:text-base dark:bg-gray-800 dark:border-gray-700 sm:p-4 sm:space-x-4 rtl:space-x-reverse",
      vertical: "space-y-4 w-72"
    }

    # @param text [String, nil] The step's title. Takes precedence over block content.
    # @param options [Hash] the arguments of Gustwave::Stepper::Step, e.g. +state+ or +description+.
    renders_many_extensible :steps, ->(text = nil, **options) {
      Gustwave::Stepper::Step.new(text, style: option_value(:style), **options)
    }

    # @param style [Symbol] +:default+ (default), +:progress+, +:detailed+, +:breadcrumb+ or +:vertical+.
    # @param options [Hash] HTML attributes for the +ol+ element.
    def initialize(style: DEFAULT, **options)
      select_options(style:)
      @options = attributes_for(options)
    end

    def before_render
      steps.each_with_index do |step, index|
        step.apply_slot_context(slot: :steps, number: index + 1, last: index == steps.size - 1)
      end
    end

    def call
      tag.ol(**@options) { slots_and_content(*steps) }
    end

    # A step of a Gustwave::Stepper, set with +with_step+. Its +state+ is
    # +:complete+, +:current+ or +:upcoming+ (default). A current step's item
    # gets +aria-current="step"+. Its +description+ shows only in the +:detailed+
    # style, and its text is for screen readers only in the +:progress+ style.
    #
    # === Icon
    #
    # +with_icon+ replaces the step's number. Pick the icon's +theme+ and pass
    # other HTML attributes, e.g. classes, the same way as for Gustwave::Icon:
    #
    #   <%= render Gustwave::Stepper.new do |stepper| %>
    #     <% stepper.with_step("Personal info", state: :complete) do |step| %>
    #       <% step.with_icon :check_circle, theme: :solid %>
    #     <% end %>
    #   <% end %>
    #
    # === Description
    #
    #   <%= render Gustwave::Stepper.new(style: :detailed) do |stepper| %>
    #     <% stepper.with_step("User info", state: :current, description: "Step details here") %>
    #   <% end %>
    #
    # @status alpha
    class Step < Gustwave::Component
      part :label
      part :indicator
      part :icon
      part :text
      part :description
      part :separator
      part :box

      variant :style, default: :default, values: {
        default: { root: "flex items-center", label: "flex items-center", indicator: "me-2", icon: "w-3.5 h-3.5 sm:w-4 sm:h-4 me-2.5" },
        progress: { root: "flex items-center w-full",
                    indicator: "flex items-center justify-center w-10 h-10 bg-gray-100 rounded-full lg:h-12 lg:w-12 dark:bg-gray-700 shrink-0",
                    icon: "w-4 h-4 text-gray-500 lg:w-5 lg:h-5 dark:text-gray-100", text: "sr-only" },
        detailed: { root: "flex items-center text-gray-500 dark:text-gray-400 space-x-2.5 rtl:space-x-reverse",
                    indicator: "flex items-center justify-center w-8 h-8 border border-gray-500 rounded-full shrink-0 dark:border-gray-400",
                    icon: "w-3.5 h-3.5", text: "font-medium leading-tight", description: "text-sm" },
        breadcrumb: { root: "flex items-center",
                      indicator: "flex items-center justify-center w-5 h-5 me-2 text-xs border border-gray-500 rounded-full shrink-0 dark:border-gray-400",
                      icon: "w-3 h-3", separator: "w-6 h-6 -my-1 ms-0.5 -me-1.5 sm:ms-2.5 rtl:rotate-180" },
        vertical: { box: "w-full p-4 text-gray-900 bg-gray-100 border border-gray-300 rounded-lg dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400",
                    label: "flex items-center justify-between", text: "font-medium", icon: "w-4 h-4" }
      }

      option :state, default: :upcoming, values: %i[complete current upcoming]

      # Set by the component from the state: a complete or current step
      toggle :active, per: :style, internal: true, values: {
        default: "text-blue-600 dark:text-blue-500",
        progress: { root: "text-blue-600 dark:text-blue-500", indicator: "bg-blue-100 dark:bg-blue-800",
                    icon: "w-3.5 h-3.5 text-blue-600 lg:w-4 lg:h-4 dark:text-blue-300" },
        detailed: { root: "text-blue-600 dark:text-blue-500", indicator: "border-blue-600 dark:border-blue-500" },
        breadcrumb: { root: "text-blue-600 dark:text-blue-500", indicator: "border-blue-600 dark:border-blue-500" },
        vertical: { box: "text-blue-700 bg-blue-100 border-blue-300 dark:border-blue-800 dark:text-blue-400" }
      }

      # Set by the component: a complete vertical step is green; declared after :active so it wins
      toggle :complete, per: :style, internal: true, values: {
        default: "", progress: "", detailed: "", breadcrumb: "",
        vertical: { box: "text-green-700 bg-green-50 border-green-300 dark:border-green-800 dark:text-green-400" }
      }

      # Set by the component: every step but the last draws a connector to the next one
      toggle :connected, per: :style, internal: true, values: {
        default: { root: "md:w-full after:content-[''] after:w-full after:h-1 after:border-b after:border-gray-200 after:border-1 after:hidden sm:after:inline-block after:mx-6 xl:after:mx-10 dark:after:border-gray-700",
                   label: "after:content-['/'] sm:after:hidden after:mx-2 after:text-gray-200 dark:after:text-gray-500" },
        progress: "after:content-[''] after:w-full after:h-1 after:border-b after:border-gray-100 after:border-4 after:inline-block dark:after:border-gray-700",
        detailed: "", breadcrumb: "", vertical: ""
      }

      # Set by the component: the connector of a complete or current step
      toggle :active_connector, per: :style, internal: true, values: {
        default: "", progress: "after:border-blue-100 dark:after:border-blue-800", detailed: "", breadcrumb: "", vertical: ""
      }

      # Renders an icon in place of the step's number. In the +:vertical+ style it sits after the title.
      #
      # @param name [Symbol] The icon to use.
      # @param theme [Symbol] +:outline+ (default) or +:solid+.
      # @param options [Hash] Additional HTML options passed to the icon component.
      renders_one_extensible :icon, ->(name, theme: :outline, **options) {
        Gustwave::Icon.new(name, theme:, **configure_html_attributes(options, class: classes(:icon), aria: { hidden: true }))
      }

      # @param text [String, nil] The step's title. Takes precedence over block content.
      # @param style [Symbol] Set by Gustwave::Stepper.
      # @param state [Symbol] +:complete+, +:current+ or +:upcoming+ (default).
      # @param description [String, nil] A line under the title. Only the +:detailed+ style shows it.
      # @param options [Hash] HTML attributes for the +li+ element.
      def initialize(text = nil, style: DEFAULT, state: DEFAULT, description: nil, **options)
        @text = text
        @description = description
        @number = nil
        @last = true
        @options = options

        select_options(style:, state:)
        select_options(active: option_value(:state) != :upcoming, complete: option_value(:state) == :complete)
      end

      # Called by Gustwave::Stepper. A step without a number, e.g. one rendered
      # on its own, shows no number.
      #
      # @param number [Integer, nil] the step's position, from 1.
      # @param last [Boolean] whether it's the last step, which draws no connector.
      def apply_slot_context(number: nil, last: true, **)
        @number = number
        @last = last
      end

      def before_render
        # Must select here, once the parent has set whether this step is the last
        select_options(connected: !@last, active_connector: option_value(:active) && !@last)
        @config = attributes_for(@options)
        @config[:"aria-current"] = "step" if option_value(:state) == :current
      end

      def call
        tag.li(**@config) {
          case option_value(:style)
          when :progress then progress_layout
          when :detailed then detailed_layout
          when :breadcrumb then breadcrumb_layout
          when :vertical then vertical_layout
          else default_layout
          end
        }
      end

      private

      def default_layout
        tag.span(safe_join([ icon? ? icon : number_tag, text_or_content(@text) ].compact), class: classes(:label))
      end

      def progress_layout
        safe_join([
          tag.span(icon? ? icon : @number, class: classes(:indicator)),
          tag.span(text_or_content(@text), class: classes(:text))
        ])
      end

      def detailed_layout
        safe_join([
          tag.span(icon? ? icon : @number, class: classes(:indicator)),
          tag.div(safe_join([ tag.h3(text_or_content(@text), class: classes(:text)), description_tag ].compact))
        ])
      end

      def breadcrumb_layout
        safe_join([
          tag.span(icon? ? icon : @number, class: classes(:indicator)),
          text_or_content(@text),
          separator
        ].compact)
      end

      def vertical_layout
        tag.div(class: classes(:box)) {
          tag.div(class: classes(:label)) {
            safe_join([ tag.h3(title_with_number, class: classes(:text)), (icon if icon?) ].compact)
          }
        }
      end

      def number_tag
        tag.span(@number, class: classes(:indicator)) if @number
      end

      def description_tag
        tag.p(@description, class: classes(:description)) if @description.present?
      end

      def separator
        return if @last

        render Gustwave::Icon.new(:chevron_double_right, class: classes(:separator), aria: { hidden: true })
      end

      def title_with_number
        return text_or_content(@text) unless @number

        safe_join([ "#{@number}. ", text_or_content(@text) ])
      end
    end
  end
end
