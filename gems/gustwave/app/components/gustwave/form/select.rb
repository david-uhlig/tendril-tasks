# frozen_string_literal: true

module Gustwave
  module Form
    # Use Select to render Flowbite's select: a drop-down list, or with
    # +multiple+ a list box, in three sizes, with a success or error look and
    # an underline style.
    #
    # +options+ are the +<select>+'s HTML attributes, e.g. +multiple+,
    # +required+, +disabled+, +name+ and +id+. The label, helper text and
    # validation message belong to Gustwave::Form::Field.
    #
    # === Choices
    #
    # The options of the select are +choices:+, anything Rails' +select+
    # takes: an array, an array of pairs of text and value, a hash, grouped
    # choices or a string of option tags, e.g. from +options_for_select+. Or
    # the block, which is the option tags, as with Rails' +select+ and
    # +select_tag+. The block wins over +choices+.
    #
    #   <%= render Gustwave::Form::Select.new(name: "country", choices: [["Canada", "CA"], ["France", "FR"]],
    #                                          prompt: "Choose a country") %>
    #
    #   <%= render Gustwave::Form::Select.new(name: "country") do %>
    #     <%= options_for_select([["Canada", "CA"], ["France", "FR"]], "FR") %>
    #   <% end %>
    #
    # +prompt+, +include_blank+, +selected+ and +include_hidden+ are Rails'
    # select options of the same name. +disabled_choices+ is Rails' +disabled+
    # select option, the values of the options to disable. It has another
    # name because +disabled: true+ is the HTML attribute that disables the
    # whole select. A select option the caller doesn't give is left to Rails,
    # so +selected: nil+ selects nothing, and not giving +selected+ selects
    # the record's value.
    #
    # === Without a form builder
    #
    # Renders a plain +<select>+. +name+ and +id+ are ordinary HTML
    # attributes, and +prompt+, +include_blank+ and +multiple+ (which adds
    # +[]+ to the name) work as in Rails' +select_tag+. There is no +id+ unless
    # the caller or a Gustwave::Form::Field gives one:
    #
    #   <%= render Gustwave::Form::Select.new(name: "year", choices: 2016..2022, selected: 2020) %>
    #
    # === With a form builder
    #
    # Pass the attribute and +form:+, a Rails form builder or any subclass.
    # Rails renders the element through its +select+ helper, so name, ID, the
    # selected option of the record, the hidden field of a +multiple+ select,
    # +index+ and +namespace+ behave as in any Rails form:
    #
    #   <%= render Gustwave::Form::Select.new(:country, form: f, choices: @countries, size: :lg) %>
    #
    # Rails' +field_error_proc+ never wraps the select. In the +error+
    # validation state the select sets +aria-invalid="true"+, unless the
    # caller's +aria+ options say otherwise.
    #
    # === Sizes and styles
    #
    # +size+ is +:sm+, +:md+ or +:lg+, and +style+ is +:default+, the bordered
    # select, or +:underline+. Flowbite shows the underline select in one
    # size and without validation looks, so with +style: :underline+ neither
    # the size's nor the validation's classes apply. +aria-invalid+ still does.
    #
    # +size+ and +style+ are also HTML attributes. The keywords are always
    # the options, so the attributes go in +html:+:
    # <tt>size: :lg, html: { size: 5, style: "min-width: 12rem" }</tt> is the
    # large select with +size="5"+ and inline CSS.
    #
    # === In a field
    #
    # Gustwave::Form::Field builds the select and wires it through
    # +apply_slot_context+ (see there):
    #
    #   <% field.with_control_select(choices: @countries, prompt: "Choose a country") %>
    #
    # @status alpha
    class Select < Gustwave::Component
      include Gustwave::Form::BoundControl

      # The select itself, which is the root element
      part :select

      # The classes shared by every size and validation state of the bordered
      # style
      base select: "block w-full border rounded-lg dark:bg-gray-700", unless: { style: :underline }

      # The bordered select, and Flowbite's underline select with its classes
      # only. They stand alone, so the underline style skips the base, size and
      # validation classes below.
      variant :style, part: :select, default: :default, values: {
        default: "",
        underline: "block py-2.5 px-0 w-full text-sm text-gray-500 bg-transparent border-0 border-b-2 border-gray-200 appearance-none dark:text-gray-400 dark:border-gray-700 focus:outline-none focus:ring-0 focus:border-gray-200 peer"
      }

      # Flowbite's sizes of the select differ from the input's
      variant :size, part: :select, default: :md, unless: { style: :underline }, values: {
        sm: "p-2 text-sm",
        md: "p-2.5 text-sm",
        lg: "px-4 py-3 text-base"
      }

      variant :validation, part: :select, default: :none, unless: { style: :underline }, values: VALIDATION_LOOK

      # There is no disabled look: Flowbite's disabled select has the classes
      # of the default one.

      # @param attribute [Symbol, String, nil] the attribute of the form's object the select is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the select is a plain +<select>+.
      # @param choices [Array, Hash, String, Range, nil] the options of the select, as Rails' +select+ takes them. The content block is used instead when there is one.
      # @param size [Symbol] the size of the select. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+. The HTML attribute +size+ goes in +html:+.
      # @param style [Symbol] the style of the select. Defaults to +:default+. Valid values are +:default+ and +:underline+. The HTML attribute +style+ goes in +html:+.
      # @param validation [Symbol] the look of the select. Defaults to +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+. The underline style has no looks.
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
        select_options(size:, style:, validation:)
      end

      def before_render
        @select_options = select_attributes
      end

      def call
        bound? ? render_bound : render_unbound
      end

      private

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

        choices = @choices.is_a?(Range) ? @choices.to_a : @choices || []
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
