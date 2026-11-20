# frozen_string_literal: true

module Gustwave
  module Form
    # Use Select to render a select: a drop-down list, or with +multiple+ a list
    # box. Like every control, it renders on its own or bound to a form builder,
    # and Gustwave::Form::Field renders it with its label: see
    # {file:README.md#Building_forms Building forms}.
    #
    #   <%= render Gustwave::Form::Select.new(name: "year", choices: 2016..2022, selected: 2020) %>
    #   <%= render Gustwave::Form::Select.new(:country, form: f, choices: @countries, size: :lg) %>
    #
    # The choices are +choices:+, e.g. an array of pairs of text and value,
    # grouped choices or a string of option tags, or the block of option tags:
    #
    #   <%= render Gustwave::Form::Select.new(name: "country") do %>
    #     <%= options_for_select([["Canada", "CA"], ["France", "FR"]], "FR") %>
    #   <% end %>
    #
    # On its own, +prompt+, +include_blank+ and +multiple+ (which adds +[]+ to
    # the name) work as in Rails' +select_tag+, and there is no +id+ unless the
    # caller or a field gives one. Bound, Rails' +select+ helper selects the
    # record's option and adds the hidden field of a +multiple+ select.
    #
    # @status alpha
    class Select < Gustwave::Component
      include Gustwave::Form::BoundControl

      # The select itself, which is the root element, with the classes shared
      # by every size and validation state of the bordered style
      part :select, "block w-full border rounded-lg dark:bg-gray-700", unless: { style: :underline }

      # The bordered select, and Flowbite's underline select with its classes
      # only. They stand alone, so the underline style skips the base, size and
      # validation classes below.
      variant :style, default: :default, values: {
        default: { select: "" },
        underline: { select: "block py-2.5 px-0 w-full text-sm text-gray-500 bg-transparent border-0 border-b-2 border-gray-200 appearance-none dark:text-gray-400 dark:border-gray-700 focus:outline-none focus:ring-0 focus:border-gray-200 peer" }
      }

      # Flowbite's sizes of the select differ from the input's. Their padding
      # overrides the chevron's room, which +chevron_room+ below restores.
      variant :size, default: :md, unless: { style: :underline }, values: {
        sm: { select: "p-2 text-sm" },
        md: { select: "p-2.5 text-sm" },
        lg: { select: "px-4 py-3 text-base" }
      }

      variant :validation, default: :none, unless: { style: :underline }, values: VALIDATION_LOOK.transform_values { |look| { select: look } }

      # Set by Gustwave::Form::InputGroup when the select sits beside addons
      variant :joined, default: :none, internal: true, unless: { style: :underline }, values: JOINED_LOOK.transform_values { |look| { select: look } }

      # Set unless the select is a list box (+multiple+, or an HTML +size+ above
      # 1). The size paddings override the end padding @tailwindcss/forms
      # reserves for the chevron, so long text would run under it: +pe-10+
      # keeps its 2.5rem. A list box has no chevron.
      toggle :chevron_room, { select: "pe-10" }, internal: true, unless: { style: :underline }

      # Set when the select is disabled. It follows the input's disabled look,
      # unlike Flowbite's docs, whose disabled select has the classes of the
      # default one, so all controls agree.
      toggle :disabled_look, per: :validation, internal: true, unless: { style: :underline },
                             values: DISABLED_LOOK.transform_values { |look| { select: look } }

      # @param attribute [Symbol, String, nil] the attribute of the form's object the select is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the select is a plain +<select>+.
      # @param choices [Array, Hash, String, ::Range, nil] the options of the select, as Rails' +select+ takes them. The content block is used instead when there is one.
      # @param size [Symbol] the size of the select. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+. The HTML attribute +size+ goes in +html:+.
      # @param style [Symbol] the style of the select. Defaults to +:default+. Valid values are +:default+, bordered, and +:underline+, which has one size and no validation looks. The HTML attribute +style+ goes in +html:+.
      # @param validation [Symbol] the look of the select. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+, unless the caller's +aria+ options say otherwise, also with the underline style.
      # @param prompt [String, Boolean] Rails' +prompt+ option: an option with no value, first in the list.
      # @param include_blank [String, Boolean] Rails' +include_blank+ option: a blank option, or one with this text.
      # @param selected [Object] Rails' +selected+ option: the value or values to select. +nil+ selects nothing. Without it a bound select selects the record's value.
      # @param disabled_choices [Object] Rails' +disabled+ select option: the value or values of the options to disable. To disable the select, pass +disabled: true+.
      # @param include_hidden [Boolean] Rails' +include_hidden+ option: whether a +multiple+ select renders its hidden field. Defaults to +true+.
      # @param options [Hash] the HTML attributes of the +<select>+, e.g. +name+, +id+, +multiple+, +required+, +disabled+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, choices: nil, size: DEFAULT, style: DEFAULT, validation: DEFAULT,
                     prompt: DEFAULT, include_blank: DEFAULT, selected: DEFAULT, disabled_choices: DEFAULT,
                     include_hidden: DEFAULT, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @choices = choices
        @rails_options = { prompt:, include_blank:, selected:, disabled: disabled_choices, include_hidden: }
                         .reject { |_name, value| value.equal?(DEFAULT) }
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        @size_given = !size.equal?(DEFAULT)
        select_options(size:, style:, validation:, chevron_room: !list_box?)
      end

      def before_render
        select_options(disabled_look: disabled?)
        @select_options = select_attributes
      end

      def call
        bound? ? render_bound : render_unbound
      end

      private

      def list_box?
        @options[:multiple].present? || (@options[:size] || @options["size"]).to_i > 1
      end

      def select_attributes
        options = attributes_for(:select, @options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end

      # Rails changes the options it gets, so it gets copies.
      def render_bound
        args = [ @choices.nil? ? [] : @choices, @rails_options.dup, @select_options ]
        if content?
          render_bound_element(:select, bound_form, bound_attribute, *args) { content }
        else
          render_bound_element(:select, bound_form, bound_attribute, *args)
        end
      end

      # Rails' +select_tag+ does the prompt and the blank option. It gets an
      # empty name, and +name+ and +id+ as HTML attributes, so there is no ID
      # unless the caller or the field gave one.
      def render_unbound
        options = @select_options.dup
        name = options.delete(:name)
        name = "#{name}[]" if name.present? && options[:multiple] == true && !name.to_s.end_with?("[]")
        options.merge!(@rails_options.slice(:prompt, :include_blank))
        helpers.select_tag("", option_tags, options.merge(name:, id: options[:id]))
      end

      def option_tags
        return content if content?
        return @choices if @choices.is_a?(String)

        choices = @choices.is_a?(::Range) ? @choices.to_a : @choices || []
        selection = { selected: @rails_options[:selected], disabled: @rails_options[:disabled] }
        if grouped_choices?(choices)
          helpers.grouped_options_for_select(choices, selection)
        else
          helpers.options_for_select(choices, selection)
        end
      end

      # As Rails tells them: the first choice is a pair whose second element
      # is an array.
      def grouped_choices?(choices)
        return false if choices.blank?

        first = choices.first
        first.is_a?(Enumerable) && first.second.is_a?(Array)
      end
    end
  end
end
