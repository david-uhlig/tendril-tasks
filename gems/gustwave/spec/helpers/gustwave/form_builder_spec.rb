# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::FormBuilder, type: :component do
  def gustwave_form(object = task, **options)
    form_builder(object, builder: described_class, **options)
  end

  def parse(html)
    Capybara.string(html.to_s)
  end

  helpers = {
    text_field: "text",
    email_field: "email",
    password_field: "password",
    number_field: "number",
    url_field: "url",
    telephone_field: "tel",
    phone_field: "tel",
    search_field: "search",
    date_field: "date",
    time_field: "time",
    datetime_field: "datetime-local",
    datetime_local_field: "datetime-local",
    month_field: "month",
    week_field: "week"
  }

  it "is a subclass of Rails' form builder" do
    expect(described_class.superclass).to eq(ActionView::Helpers::FormBuilder)
  end

  helpers.each do |helper, type|
    it "renders #{helper} as a field with an input of type #{type}" do
      html = parse(gustwave_form.public_send(helper, :title))

      expect(html).to have_css("div > label[for='task_title'] + input#task_title[name='task[title]'][type='#{type}']")
    end
  end

  describe "option routing" do
    it "sends label, helper text, validation and message to the field" do
      html = parse(gustwave_form.text_field(:title, label: "Name", helper_text: "Help", validation: :success,
                                                    validation_message: "Fine"))

      expect(html.find("label").text).to eq("Name")
      expect(html).to have_css("p#task_title_helper_text", text: "Help")
      expect(html).to have_css("p#task_title_validation_message.text-green-600", text: "Fine")
    end

    it "sends size and icon to the input, and the rest is its HTML attributes" do
      html = parse(gustwave_form.text_field(:title, size: :lg, icon: :envelope, class: "shadow-xs", placeholder: "Title",
                                                    required: true, data: { x: "1" }, aria: { label: "T" }, value: "v"))
      input = html.find("input")

      expect(input[:class].split).to include("p-4", "ps-10", "shadow-xs")
      expect(input[:placeholder]).to eq("Title")
      expect(input[:required]).to be_present
      expect(input["data-x"]).to eq("1")
      expect(input["aria-label"]).to eq("T")
      expect(input[:value]).to eq("v")
      expect(html).to have_css("div > div.relative > div.absolute > svg")
    end

    it "passes html: to the input, next to its size" do
      input = parse(gustwave_form.text_field(:title, size: :lg, html: { size: 20 }, placeholder: "p")).find("input")

      expect(input[:size]).to eq("20")
      expect(input[:placeholder]).to eq("p")
      expect(class_set(input[:class])).to eq(class_set(FormSpecHelpers::FLOWBITE_INPUT_LARGE))
    end

    it "raises for a size that is an HTML attribute, and names html:" do
      expect { gustwave_form.text_field(:title, size: 20) }
        .to raise_error(Gustwave::Options::UnknownValueError, /pass html: \{ size: 20 \}\./)
    end

    it "accepts string keys" do
      html = parse(gustwave_form.text_field(:title, "helper_text" => "Help", "size" => :sm, "placeholder" => "P"))

      expect(html).to have_css("p", text: "Help")
      expect(html.find("input")[:class].split).to include("p-2")
      expect(html.find("input")[:placeholder]).to eq("P")
    end

    it "renders no label for label: false" do
      expect(parse(gustwave_form.text_field(:title, label: false))).to have_no_css("label")
    end
  end

  it "passes the field to a block" do
    yielded = nil
    html = parse(gustwave_form.text_field(:title) do |field|
      yielded = field
      field.with_helper_text("From the block")
    end)

    expect(yielded).to be_a(Gustwave::Form::Field)
    expect(html).to have_css("p#task_title_helper_text", text: "From the block")
    expect(html).to have_css("input[aria-describedby='task_title_helper_text']")
  end

  it "marks the input as invalid for a record with errors" do
    html = parse(gustwave_form(invalid_task).text_field(:title))

    expect(html).to have_css("input[aria-invalid='true']")
    expect(html).to have_css("p", text: "Can't be blank")
    expect(html).to have_no_css(".field_with_errors")
  end

  %i[text_area textarea].each do |helper|
    describe "##{helper}" do
      it "renders a field with a textarea" do
        html = parse(gustwave_form(task(title: "Write")).public_send(helper, :title))

        expect(html).to have_css("div > label[for='task_title'] + textarea#task_title[name='task[title]']", text: "Write")
      end

      it "sends HTML options to the textarea and field options to the field" do
        html = parse(gustwave_form.public_send(helper, :title, label: "Notes", helper_text: "Help", validation: :success,
                                                               rows: 4, placeholder: "P", class: "shadow-xs"))

        expect(html.find("label").text).to eq("Notes")
        expect(html).to have_css("p#task_title_helper_text", text: "Help")
        expect(html).to have_css("textarea[rows='4'][placeholder='P'][aria-describedby='task_title_helper_text']")
        expect(html.find("textarea")[:class].split).to include("shadow-xs", "bg-green-50")
      end

      it "gives cols and rows for Rails' size option" do
        textarea = parse(gustwave_form.public_send(helper, :title, size: "20x40")).find("textarea")

        expect(textarea[:cols]).to eq("20")
        expect(textarea[:rows]).to eq("40")
      end

      it "passes the field to a block" do
        html = parse(gustwave_form.public_send(helper, :title) { |field| field.with_helper_text("From the block") })

        expect(html).to have_css("p#task_title_helper_text", text: "From the block")
      end
    end
  end

  it "leaves rich_textarea to Rails" do
    expect(described_class.instance_method(:rich_textarea).owner).to eq(ActionView::Helpers::FormBuilder)
  end

  it "leaves other helpers to Rails" do
    plain = form_builder.hidden_field(:title, value: "x")

    expect(gustwave_form.hidden_field(:title, value: "x")).to eq(plain)
    expect(gustwave_form.hidden_field(:title, value: "x")).to include('type="hidden"')
  end

  it "doesn't change Rails' default form builder" do
    expect(ActionView::Base.default_form_builder).not_to eq(described_class)
  end

  describe "switching a plain form_with to the builder" do
    def form_html(**options)
      vc_test_controller.view_context.form_with(model: task(title: "Write", due_on: Date.new(2026, 3, 9)),
                                                url: "/tasks", scope: :task, **options) do |f|
        f.text_field(:title, placeholder: "Title") + f.date_field(:due_on) + f.hidden_field(:project_id)
      end
    end

    it "keeps name, id and value of the inputs" do
      plain = parse(form_html)
      gustwave = parse(form_html(builder: described_class))

      %w[task_title task_due_on].each do |id|
        before = plain.find("input##{id}")
        after = gustwave.find("input##{id}")

        expect(after[:name]).to eq(before[:name])
        expect(after[:value]).to eq(before[:value])
        expect(after[:type]).to eq(before[:type])
      end
      expect(gustwave.find("input#task_title")[:placeholder]).to eq("Title")
      expect(gustwave).to have_css("input[type='hidden'][name='task[project_id]']", visible: :all)
    end
  end

  describe "in an ERB template" do
    def render_erb(erb, **locals)
      parse(vc_test_controller.view_context.render(inline: erb, locals:))
    end

    it "renders a field for an invalid record, a field with an icon and helper text, and leaves hidden fields alone" do
      html = render_erb(<<~ERB, record: invalid_task)
        <%= form_with model: record, scope: :task, url: "/tasks", builder: Gustwave::FormBuilder do |f| %>
          <%= f.text_field :title, placeholder: "Title" %>
          <%= f.text_field :password, icon: :envelope, helper_text: "At least 8 characters." %>
          <%= f.hidden_field :project_id %>
        <% end %>
      ERB

      expect(html).to have_css("label[for='task_title']", text: "Title")
      expect(html).to have_css("input#task_title[aria-invalid='true'][aria-describedby='task_title_validation_message']")
      expect(html).to have_css("p#task_title_validation_message", text: "Can't be blank")
      expect(html).to have_no_css(".field_with_errors")

      expect(html).to have_css("div.relative > div svg + input#task_password, div.relative > div + input#task_password[aria-describedby='task_password_helper_text']")
      expect(html).to have_css("p#task_password_helper_text", text: "At least 8 characters.")

      expect(html).to have_css("input[type='hidden'][name='task[project_id]']", visible: :all)
      expect(html).to have_no_css("input[type='hidden'] + p, label[for='task_project_id']", visible: :all)
    end

    it "renders a field with a textarea" do
      html = render_erb(<<~ERB, record: invalid_task)
        <%= form_with model: record, scope: :task, url: "/tasks", builder: Gustwave::FormBuilder do |f| %>
          <%= f.text_area :title, rows: 4, helper_text: "Shown in the list." %>
        <% end %>
      ERB

      expect(html).to have_css("label[for='task_title']")
      expect(html).to have_css("textarea#task_title[name='task[title]'][rows='4'][aria-invalid='true']")
      expect(html).to have_css("textarea[aria-describedby='task_title_helper_text task_title_validation_message']")
      expect(html).to have_no_css(".field_with_errors")
    end

    it "renders a link in the helper text of an ERB block" do
      html = render_erb(<<~ERB, record: task)
        <%= form_with model: record, scope: :task, url: "/tasks", builder: Gustwave::FormBuilder do |f| %>
          <%= f.password_field :password do |field| %><% field.with_helper_text do %>Read our <a href="/rules">rules</a>.<% end %><% end %>
        <% end %>
      ERB

      expect(html).to have_css("p#task_password_helper_text", text: "Read our rules.")
      expect(html).to have_css("p#task_password_helper_text a[href='/rules']", text: "rules")
      expect(html).to have_css("input[type='password'][aria-describedby='task_password_helper_text']")
    end

    it "renders a Form::Field inside a form with Rails' default builder" do
      html = render_erb(<<~ERB, record: task)
        <%= form_with model: record, scope: :task, url: "/tasks" do |f| %>
          <%= render Gustwave::Form::Field.new(:title, form: f, validation: :error) do |field| %>
            <% field.with_label("Task title") %>
            <% field.with_control_input %>
            <% field.with_validation_message do %><b>Oops!</b> Pick another title.<% end %>
          <% end %>
        <% end %>
      ERB

      expect(html).to have_css("label[for='task_title']", text: "Task title")
      expect(html).to have_css("input#task_title[name='task[title]'][aria-invalid='true'][aria-describedby='task_title_validation_message']")
      expect(html).to have_css("p#task_title_validation_message b", text: "Oops!")
    end
  end

  describe "extending it" do
    it "renders the field class of a subclass" do
      stub_const("SpecField", Class.new(Gustwave::Form::Field) {
        def call = tag.section(super, class: "spec-field")
      })
      stub_const("SpecBuilder", Class.new(described_class) { self.field_class = "SpecField" })

      html = parse(form_builder(builder: SpecBuilder).text_field(:title))

      expect(html).to have_css("section.spec-field input#task_title")
      expect(described_class.field_class).to eq("Gustwave::Form::Field")
    end

    it "adds helpers with render_field" do
      stub_const("SpecBuilder", Class.new(described_class) {
        def search(attribute, options = {}, &block) = render_field(attribute, :input, options.merge(type: :search), &block)
      })

      html = parse(form_builder(builder: SpecBuilder).search(:title, helper_text: "Find"))

      expect(html).to have_css("input[type='search'][name='task[title]']")
      expect(html).to have_css("p", text: "Find")
    end

    it "renders a control a field subclass adds" do
      stub_const("SpecField", Class.new(Gustwave::Form::Field) {
        extend_slot :control, types: { box: ->(**options) { Gustwave::Form::Input.new(type: :search, **options) } }
      })
      stub_const("SpecBuilder", Class.new(described_class) {
        self.field_class = "SpecField"
        def box(attribute, options = {}, &block) = render_field(attribute, :box, options, &block)
      })

      html = parse(form_builder(builder: SpecBuilder).box(:title, name: "t[title]"))

      expect(html).to have_css("label + input[type='search'][name='t[title]']")
    end
  end
end
