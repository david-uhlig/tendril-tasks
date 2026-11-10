# frozen_string_literal: true

module Gustwave
  # A form builder that renders Rails' input helpers as Gustwave::Form::Field
  # with a Gustwave::Form::Input. A form opts in with +builder:+. Gustwave
  # never sets +default_form_builder+ (D10 in docs/design.md).
  #
  #   <%= form_with model: @task, builder: Gustwave::FormBuilder do |f| %>
  #     <%= f.text_field :title, helper_text: "Shown in the task list." %>
  #     <%= f.email_field :contact, icon: :envelope, size: :lg, placeholder: "name@example.com" %>
  #     <%= f.hidden_field :project_id %>
  #   <% end %>
  #
  # The helpers keep Rails' names and signatures, so switching a form to the
  # builder changes no call: HTML options still go to the +<input>+. They also
  # take the field's +label+, +helper_text+, +validation+ and
  # +validation_message+ and the input's +size+ and +icon+. A block receives
  # the field, to set its slots:
  #
  #   <%= f.text_field :title do |field| %>
  #     <% field.with_helper_text { "Read our #{link_to("rules", rules_path)}.".html_safe } %>
  #   <% end %>
  #
  # Overridden: +text_field+, +email_field+, +password_field+, +number_field+,
  # +url_field+, +telephone_field+ (+phone_field+), +search_field+,
  # +date_field+, +time_field+, +datetime_field+, +datetime_local_field+,
  # +month_field+ and +week_field+. Every other helper stays Rails'.
  #
  # The builder holds no markup or classes. Whatever it renders can be
  # rendered with Gustwave::Form::Field and Gustwave::Form::Input directly.
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

    # The options that go to the field. The rest goes to the control: +size+
    # and +icon+ are its options, everything else the HTML attributes of the
    # form element.
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

    # Renders a field for +attribute+ with a control of the slot type
    # +control+, e.g. +:input+ or one an app adds to Gustwave::Form::Field
    # with +extend_slot+. This is what every helper calls, and the one to call
    # for a helper of an app's own.
    #
    # @param attribute [Symbol, String] the attribute.
    # @param control [Symbol] the type of the field's +control+ slot.
    # @param options [Hash] +label+, +helper_text+, +validation+ and +validation_message+ go to the field, +size+ and +icon+ to the control, and the rest are the HTML attributes of the form element. String keys are accepted.
    # @yield [field] the field, to set its slots.
    # @return [ActiveSupport::SafeBuffer]
    def render_field(attribute, control, options = {}, &block)
      options = options.to_h.symbolize_keys
      field_options = options.slice(*FIELD_OPTIONS)
      control_options = options.except(*FIELD_OPTIONS)
      field = field_class.to_s.constantize.new(attribute, form: self, **field_options)

      @template.render(field) do |rendered|
        rendered.with_control(control, **control_options)
        block&.call(rendered)
      end
    end
  end
end
