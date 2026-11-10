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

  describe "#select" do
    let(:countries) { [ %w[Canada CA], %w[France FR], %w[Germany DE] ] }

    def selected_values(html) = html.all("option[selected]").map { |option| option[:value] }

    it "renders a field with a select, with the record's value selected" do
      html = parse(gustwave_form(task(country: "FR")).select(:country, countries))

      expect(html).to have_css("div > label[for='task_country'] + select#task_country[name='task[country]']")
      expect(html.all("option").map { |option| option[:value] }).to eq(%w[CA FR DE])
      expect(selected_values(html)).to eq([ "FR" ])
    end

    it "sends Rails' select options, the field's options and size and style to the right place" do
      html = parse(gustwave_form.select(:country, countries, prompt: "Choose", disabled: "DE", size: :lg,
                                                             style: :underline, label: "Where", helper_text: "Help",
                                                             validation: :success, validation_message: "Fine"))
      select = html.find("select")

      expect(html.find("label").text).to eq("Where")
      expect(html).to have_css("p#task_country_helper_text", text: "Help")
      expect(html).to have_css("p#task_country_validation_message.text-green-600", text: "Fine")
      expect(html.all("option").map { |option| option[:value] }).to eq([ "", "CA", "FR", "DE" ])
      expect(html.find("option", text: "Choose")[:value]).to eq("")
      expect(html.all("option[disabled]").map { |option| option[:value] }).to eq([ "DE" ])
      expect(selected_values(html)).to be_empty
      expect(select[:disabled]).to be_nil
      expect(class_set(select[:class])).to eq(class_set(FormSpecHelpers::FLOWBITE_SELECT_UNDERLINE))
      expect(select[:size]).to be_nil
      expect(select[:style]).to be_nil
    end

    it "takes size as an option in the first hash and as an attribute in the second" do
      select = parse(gustwave_form.select(:country, countries, { size: :lg }, { size: 5 })).find("select")

      expect(select[:size]).to eq("5")
      expect(class_set(select[:class])).to eq(class_set(FormSpecHelpers::FLOWBITE_SELECT_LARGE))
    end

    it "merges html: of the first hash under the second hash" do
      select = parse(gustwave_form.select(:country, countries, { html: { size: 3, style: "x: y" } }, { size: 5 })).find("select")

      expect(select[:size]).to eq("5")
      expect(select[:style]).to eq("x: y")
    end

    it "raises for an html: in the first hash that isn't a hash" do
      expect { gustwave_form.select(:country, countries, { html: "nope" }) }
        .to raise_error(ArgumentError, 'html: takes a Hash of HTML attributes, got "nope"')
    end

    it "takes the large size without a hash around the options" do
      select = parse(gustwave_form.select(:country, countries, size: :lg)).find("select")

      expect(class_set(select[:class])).to eq(class_set(FormSpecHelpers::FLOWBITE_SELECT_LARGE))
    end

    it "takes the HTML attributes from the second hash, where size and style stay attributes" do
      html = parse(gustwave_form.select(:country, countries, {}, { size: 5, style: "min-width: 12rem", class: "shadow-xs",
                                                                  required: true, data: { x: "1" } }))
      select = html.find("select")

      expect(select[:size]).to eq("5")
      expect(select[:style]).to eq("min-width: 12rem")
      expect(select[:required]).to be_present
      expect(select["data-x"]).to eq("1")
      expect(class_set(select[:class])).to include("shadow-xs", "p-2.5")
    end

    it "renders a multiple select with Rails' hidden field" do
      html = parse(gustwave_form(task(tags: %w[b])).select(:tags, %w[a b], {}, multiple: true))

      expect(html).to have_css("input[type='hidden'][name='task[tags][]'] + select#task_tags[name='task[tags][]'][multiple]", visible: :all)
      expect(selected_values(html)).to eq(%w[b])
    end

    it "reads multiple and include_hidden from the options, as Rails does" do
      html = parse(gustwave_form.select(:tags, %w[a b], multiple: true, include_hidden: false, required: true))

      expect(html).to have_css("select[multiple][required]")
      expect(html).to have_no_css("input", visible: :all)
    end

    it "takes the option tags from the block, which doesn't get the field" do
      yielded = nil
      view = vc_test_controller.view_context
      html = parse(gustwave_form(task(country: "FR")).select(:country, nil, { prompt: "Choose" }) do |*args|
        yielded = args
        view.options_for_select(countries, "DE")
      end)

      expect(yielded).to be_empty
      expect(html.all("option").map { |option| option[:value] }).to eq(%w[CA FR DE])
      expect(selected_values(html)).to eq([ "DE" ])
    end

    it "gives the same name, ID and selected option as Rails' own builder" do
      record = task(country: "DE")
      ours = parse(gustwave_form(record, index: 2, namespace: "ns").select(:country, countries, { include_blank: true }, { required: true })).find("select")
      rails = parse(form_builder(record, index: 2, namespace: "ns").select(:country, countries, { include_blank: true }, { required: true })).find("select")

      expect(ours[:name]).to eq(rails[:name])
      expect(ours[:id]).to eq(rails[:id])
      expect(ours.all("option").map { |option| [ option[:value], option[:selected] ] })
        .to eq(rails.all("option").map { |option| [ option[:value], option[:selected] ] })
    end

    it "shows the errors of the attribute" do
      html = parse(gustwave_form(invalid_task).select(:title, %w[a]))

      expect(html).to have_css("select[aria-invalid='true']")
      expect(html).to have_css("p", text: "Can't be blank")
      expect(html).to have_no_css(".field_with_errors")
    end

    it "drops options Rails doesn't know" do
      expect { gustwave_form.select(:country, countries, unknown: 1) }.not_to raise_error
    end
  end

  describe "#collection_select" do
    let(:countries) { [ Struct.new(:name, :code).new("Canada", "CA"), Struct.new(:name, :code).new("France", "FR") ] }

    def selected_values(html) = html.all("option[selected]").map { |option| option[:value] }

    it "renders a field with a select from method names, with the record's value selected" do
      html = parse(gustwave_form(task(country: "FR")).collection_select(:country, countries, :code, :name))

      expect(html).to have_css("label[for='task_country'] + select#task_country[name='task[country]']")
      expect(html.all("option").map { |option| [ option.text, option[:value] ] }).to eq([ %w[Canada CA], %w[France FR] ])
      expect(selected_values(html)).to eq([ "FR" ])
    end

    it "takes a lambda as the text method" do
      html = parse(gustwave_form.collection_select(:country, countries, :code, ->(country) { "#{country.name} (#{country.code})" }))

      expect(html.all("option").map(&:text)).to eq([ "Canada (CA)", "France (FR)" ])
    end

    it "takes a lambda as the value method" do
      html = parse(gustwave_form.collection_select(:country, countries, ->(country) { country.code.downcase }, :name))

      expect(html.all("option").map { |option| option[:value] }).to eq(%w[ca fr])
    end

    it "turns a Proc for selected and disabled into the values it picks" do
      html = parse(gustwave_form.collection_select(:country, countries, :code, :name,
                                                   selected: ->(country) { country.code == "CA" },
                                                   disabled: proc { |country| country.code == "FR" }))

      expect(selected_values(html)).to eq([ "CA" ])
      expect(html.all("option[disabled]").map { |option| option[:value] }).to eq([ "FR" ])
    end

    it "takes plain values for selected and disabled" do
      html = parse(gustwave_form(task(country: "FR")).collection_select(:country, countries, :code, :name, selected: "CA", disabled: "FR"))

      expect(selected_values(html)).to eq([ "CA" ])
      expect(html.all("option[disabled]").map { |option| option[:value] }).to eq([ "FR" ])
    end

    it "sends options and HTML attributes as select does" do
      html = parse(gustwave_form.collection_select(:country, countries, :code, :name,
                                                   { include_blank: true, label: "Country", helper_text: "Help" },
                                                   { size: 3, class: "shadow-xs" }))
      select = html.find("select")

      expect(html.find("label").text).to eq("Country")
      expect(html).to have_css("p#task_country_helper_text", text: "Help")
      expect(html.all("option").first[:value]).to eq("")
      expect(select[:size]).to eq("3")
      expect(class_set(select[:class])).to include("shadow-xs", "p-2.5")
    end

    it "takes style as an option in the first hash and as an attribute in the second" do
      select = parse(gustwave_form.collection_select(:country, countries, :code, :name, { style: :underline },
                                                     { style: "color: red" })).find("select")

      expect(select[:style]).to eq("color: red")
      expect(class_set(select[:class])).to eq(class_set(FormSpecHelpers::FLOWBITE_SELECT_UNDERLINE))
    end

    it "renders the same name, ID and options as Rails' own builder" do
      record = task(country: "CA")
      ours = parse(gustwave_form(record).collection_select(:country, countries, :code, :name, include_blank: true)).find("select")
      rails = parse(form_builder(record).collection_select(:country, countries, :code, :name, include_blank: true)).find("select")

      expect(ours[:name]).to eq(rails[:name])
      expect(ours[:id]).to eq(rails[:id])
      expect(ours.all("option").map { |option| [ option.text, option[:value], option[:selected] ] })
        .to eq(rails.all("option").map { |option| [ option.text, option[:value], option[:selected] ] })
    end
  end

  it "leaves the other select helpers to Rails" do
    %i[grouped_collection_select time_zone_select weekday_select date_select].each do |helper|
      expect(described_class.instance_method(helper).owner).to eq(ActionView::Helpers::FormBuilder), helper.to_s
    end
  end

  %i[rich_textarea rich_text_area].each do |helper|
    describe "##{helper}" do
      it "renders a field with a framed rich textarea" do
        html = parse(gustwave_form(task(body: "Hi")).public_send(helper, :body))

        expect(html).to have_css("div > label[for='task_body'] + div.rounded-lg")
        expect(html).to have_css("[toolbar][id='task_body']", visible: :all)
        expect(html).to have_css("lexxy-toolbar")
        expect(html).to have_css("input[type='hidden'][name='task[body]']", visible: :all)
      end

      it "sends helper_text to the field and aria-describedby to the editor" do
        html = parse(gustwave_form.public_send(helper, :body, helper_text: "Help"))

        expect(html).to have_css("p#task_body_helper_text", text: "Help")
        expect(html.find("[toolbar]")["aria-describedby"]).to eq("task_body_helper_text")
      end

      it "sends editor and placeholder to the rich textarea and the editor element" do
        html = parse(gustwave_form.public_send(helper, :body, editor: :trix, placeholder: "Write"))
        editor = html.find("[toolbar]", visible: :all)

        expect(html).to have_css("trix-toolbar")
        expect(editor[:class].split).to include("trix-content")
        expect(editor[:placeholder]).to eq("Write")
      end

      it "passes the field to a block" do
        html = parse(gustwave_form.public_send(helper, :body) { |field| field.with_helper_text("From the block") })

        expect(html).to have_css("p#task_body_helper_text", text: "From the block")
      end
    end
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

    it "renders a field with a rich textarea" do
      html = render_erb(<<~ERB, record: task(body: "Hi"))
        <%= form_with model: record, scope: :task, url: "/tasks", builder: Gustwave::FormBuilder do |f| %>
          <%= f.rich_text_area :body, label: "Body", helper_text: "Shown on the page." %>
        <% end %>
      ERB

      expect(html).to have_css("label[for='task_body']", text: "Body")
      expect(html).to have_css("p#task_body_helper_text", text: "Shown on the page.")
      expect(html).to have_css("[toolbar][id='task_body'][aria-describedby='task_body_helper_text']", visible: :all)
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

    it "renders selects, with the options of a block, a prompt, a multiple select and a collection" do
      html = render_erb(<<~ERB, record: task(country: "FR"))
        <%= form_with model: record, scope: :task, url: "/tasks", builder: Gustwave::FormBuilder do |f| %>
          <%= f.select :country, [["Canada", "CA"], ["France", "FR"]], prompt: "Choose a country", size: :lg, helper_text: "Where you live." %>
          <%= f.select :title, nil, { label: "Block" } do %>
            <%= options_for_select(["a", "b"], "b") %>
          <% end %>
          <%= f.select :tags, %w[a b c], { label: "Tags" }, { multiple: true, size: 3 } %>
          <%= f.collection_select :project_id, [Struct.new(:id, :name).new(1, "Alpha")], :id, :name, prompt: "Choose a project" %>
        <% end %>
      ERB

      expect(html).to have_css("label[for='task_country']", text: "Country")
      expect(html).to have_css("select#task_country[aria-describedby='task_country_helper_text'] option[selected][value='FR']")
      expect(html).to have_css("p#task_country_helper_text", text: "Where you live.")
      expect(html).to have_css("label[for='task_title']", text: "Block")
      expect(html).to have_css("select#task_title option[selected]", text: "b")
      expect(html).to have_css("select#task_tags[multiple][size='3'][name='task[tags][]']")
      expect(html).to have_css("label[for='task_project_id'] + select#task_project_id option[value='1']", text: "Alpha")
      expect(html).to have_css("select#task_project_id option[value='']", text: "Choose a project")
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
