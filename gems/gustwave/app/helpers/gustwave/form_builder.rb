# frozen_string_literal: true

module Gustwave
  # A form builder that renders Rails' input, text area, rich text area and
  # select helpers as Gustwave::Form::Field with a Gustwave::Form::Input,
  # Gustwave::Form::Textarea, Gustwave::Form::RichTextarea or
  # Gustwave::Form::Select. A form opts in with
  # +builder:+. Gustwave never sets +default_form_builder+ (D10 in
  # docs/design.md).
  #
  #   <%= form_with model: @task, builder: Gustwave::FormBuilder do |f| %>
  #     <%= f.text_field :title, helper_text: "Shown in the task list." %>
  #     <%= f.email_field :contact, icon: :envelope, size: :lg, placeholder: "name@example.com" %>
  #     <%= f.text_area :notes, rows: 4 %>
  #     <%= f.select :country, @countries, prompt: "Choose a country", size: :lg %>
  #     <%= f.hidden_field :project_id %>
  #   <% end %>
  #
  # The helpers keep Rails' names and signatures, so switching a form to the
  # builder changes no call: HTML options still go to the +<input>+ or
  # +<textarea>+. They also take the field's +label+, +helper_text+,
  # +validation+ and +validation_message+ and the input's +size+ and +icon+.
  # +size+ is Gustwave's size, so the HTML attribute goes in +html:+, e.g.
  # <tt>f.text_field :title, html: { size: 20 }</tt>. A block receives the
  # field, to set its slots:
  #
  #   <%= f.text_field :title do |field| %>
  #     <% field.with_helper_text { "Read our #{link_to("rules", rules_path)}.".html_safe } %>
  #   <% end %>
  #
  # +select+ and +collection_select+ take two hashes, as in Rails. The first
  # holds Rails' select options (+prompt+, +include_blank+, +selected+,
  # +disabled+, +include_hidden+) and Gustwave's: the field's +label+,
  # +helper_text+, +validation+ and +validation_message+ and the select's
  # +size+ and +style+. The second is the +<select>+'s HTML attributes and
  # goes to the select as +html:+, so a +size+ or +style+ in it is the HTML
  # attribute: <tt>f.select :tags, @tags, { size: :lg }, { size: 5 }</tt>.
  # The block of +select+ stays Rails': it supplies the option tags, and
  # doesn't receive the field. Set a select's slots with
  # Gustwave::Form::Field directly:
  #
  #   <%= f.select :country, @countries, prompt: "Choose a country", size: :lg, helper_text: "Where you live." %>
  #   <%= f.select :tags, @tags, {}, multiple: true, size: 5 %>
  #   <%= f.collection_select :country_id, Country.all, :id, :name, include_blank: true %>
  #
  # Overridden: +text_field+, +email_field+, +password_field+, +number_field+,
  # +url_field+, +telephone_field+ (+phone_field+), +search_field+,
  # +date_field+, +time_field+, +datetime_field+, +datetime_local_field+,
  # +month_field+ and +week_field+, which render an input, +textarea+
  # (+text_area+) and +rich_textarea+ (+rich_text_area+), which render a
  # textarea and a rich textarea, and +select+ and +collection_select+, which
  # render a select. Every other helper stays Rails', including the other
  # select helpers such as +grouped_collection_select+ and +time_zone_select+.
  #
  # The rich textarea's +editor+, +sticky_toolbar+ and +toolbar_id+ are its
  # options, and the rest of the options are the editor element's attributes.
  #
  # The builder holds no markup or classes. Whatever it renders can be
  # rendered with Gustwave::Form::Field and its control directly.
  #
  # === Extending
  #
  # An app's subclass renders its own field class with +field_class+, and
  # adds helpers for its own controls with +render_field+:
  #
  #   class AppFormBuilder < Gustwave::FormBuilder
  #     self.field_class = "App::Field"
  #
  #     def toggle(attribute, options = {}, &block)
  #       render_field(attribute, :toggle, options, &block)
  #     end
  #   end
  #
  # @status alpha
  class FormBuilder < ActionView::Helpers::FormBuilder
    # The field class the helpers render, as a class or class name. Set it on
    # a subclass, with a class name so it survives code reloading. Part of
    # the extension API, see docs/design.md, "Public API and stability".
    class_attribute :field_class,
                    instance_writer: false,
                    instance_predicate: false,
                    default: "Gustwave::Form::Field"

    # The options that go to the field. The rest goes to the control: an
    # input's +size+ and +icon+ are its options, everything else the HTML
    # attributes of the form element. +html:+ goes to the control, too.
    FIELD_OPTIONS = %i[label helper_text validation validation_message].freeze

    # The input type each overridden helper renders
    INPUT_TYPES = {
      text_field: :text,
      email_field: :email,
      password_field: :password,
      number_field: :number,
      url_field: :url,
      telephone_field: :tel,
      search_field: :search,
      date_field: :date,
      time_field: :time,
      datetime_field: :datetime_local,
      datetime_local_field: :datetime_local,
      month_field: :month,
      week_field: :week
    }.freeze

    INPUT_TYPES.each do |helper, type|
      define_method(helper) do |attribute, options = {}, &block|
        render_field(attribute, :input, options.to_h.symbolize_keys.merge(type:), &block)
      end
    end

    alias_method :phone_field, :telephone_field

    # Renders a field with a Gustwave::Form::Textarea. Rails' +size: "20x40"+
    # still sets +cols+ and +rows+.
    def textarea(attribute, options = {}, &block)
      render_field(attribute, :textarea, options, &block)
    end
    alias_method :text_area, :textarea

    # Renders a field with a Gustwave::Form::RichTextarea. The block receives
    # the field, as for the input helpers.
    def rich_textarea(attribute, options = {}, &block)
      render_field(attribute, :rich_textarea, options, &block)
    end
    alias_method :rich_text_area, :rich_textarea

    # The options of a select helper that go to the control as they are.
    # +disabled+ goes as +disabled_choices+.
    SELECT_CONTROL_OPTIONS = %i[size style prompt include_blank selected include_hidden].freeze

    # Rails reads these from the options of a select, too, when the HTML
    # attributes don't have them.
    SELECT_HTML_OPTIONS = %i[required multiple].freeze

    # Renders a field with a Gustwave::Form::Select. +options+ holds Rails'
    # select options and Gustwave's, +html_options+ the +<select>+'s HTML
    # attributes. The block is Rails': it supplies the option tags and doesn't
    # receive the field.
    #
    # @param attribute [Symbol, String] the attribute.
    # @param choices [Array, Hash, String, nil] the choices, as Rails' +select+ takes them.
    # @param options [Hash] Rails' +prompt+, +include_blank+, +selected+, +disabled+ and +include_hidden+, the field's +label+, +helper_text+, +validation+ and +validation_message+, and the select's +size+ and +style+.
    # @param html_options [Hash] the HTML attributes of the +<select>+, passed to it as +html:+.
    # @yield the option tags, instead of +choices+.
    # @return [ActiveSupport::SafeBuffer]
    def select(attribute, choices = nil, options = {}, html_options = {}, &block)
      choices = @template.capture { block.call || "" } if block
      render_select(attribute, choices, options, html_options)
    end

    # Renders a field with a Gustwave::Form::Select, for a collection of
    # objects. +value_method+ and +text_method+ are method names or anything
    # that responds to +call+, and +selected+ and +disabled+ may be a Proc that
    # tells which objects, as in Rails. Takes the options of +select+.
    def collection_select(attribute, collection, value_method, text_method, options = {}, html_options = {})
      options = options.to_h.symbolize_keys
      choices = collection.map do |item|
        [ collection_value(item, text_method), collection_value(item, value_method) ]
      end
      %i[selected disabled].each do |key|
        next unless options[key].is_a?(Proc)

        options[key] = collection.filter_map { |item| collection_value(item, value_method) if options[key].call(item) }
      end
      render_select(attribute, choices, options, html_options)
    end

    # Renders a field for +attribute+ with a control of the slot type
    # +control+, e.g. +:input+ or one an app adds to Gustwave::Form::Field
    # with +extend_slot+. This is what every helper calls, and the one to call
    # for a helper of an app's own.
    #
    # @param attribute [Symbol, String] the attribute.
    # @param control [Symbol] the type of the field's +control+ slot.
    # @param options [Hash] +label+, +helper_text+, +validation+ and +validation_message+ go to the field, an input's +size+ and +icon+ to the control, and the rest are the HTML attributes of the form element. String keys are accepted. +html:+ holds HTML attributes of the form element, also those named like an option of the control.
    # @yield [field] the field, to set its slots.
    # @return [ActiveSupport::SafeBuffer]
    def render_field(attribute, control, options = {}, &block)
      options = options.to_h.symbolize_keys
      render_field_with(attribute, control, options.slice(*FIELD_OPTIONS), options.except(*FIELD_OPTIONS), &block)
    end

    private

    # Renders the field with its own options and the control's.
    def render_field_with(attribute, control, field_options, control_options, &block)
      field = field_class.to_s.constantize.new(attribute, form: self, **field_options)

      @template.render(field) do |rendered|
        rendered.with_control(control, **control_options)
        block&.call(rendered)
      end
    end

    # Sends each option of a select helper to the field or to the control,
    # and the HTML attributes to the control as +html:+, so one named like
    # an option of the select stays an attribute. An +html+ in the options
    # counts as HTML attributes, which +html_options+ win over. Options
    # Rails doesn't know are dropped, as Rails ignores them.
    def render_select(attribute, choices, options, html_options)
      options = options.to_h.symbolize_keys
      html_options = Gustwave::HtmlAttributesHelper.merge_html(html: options[:html]).merge(html_options.to_h.symbolize_keys)
      SELECT_HTML_OPTIONS.each do |key|
        html_options[key] = options[key] if options.key?(key) && !html_options.key?(key)
      end

      control_options = options.slice(*SELECT_CONTROL_OPTIONS).merge(choices:)
      control_options[:disabled_choices] = options[:disabled] if options.key?(:disabled)
      control_options[:html] = html_options if html_options.any?
      render_field_with(attribute, :select, options.slice(*FIELD_OPTIONS), control_options)
    end

    def collection_value(item, method)
      method.respond_to?(:call) ? method.call(item) : item.public_send(method)
    end
  end
end
