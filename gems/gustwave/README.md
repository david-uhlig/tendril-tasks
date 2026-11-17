# Gustwave

Gustwave is an unofficial implementation of the [Flowbite](https://flowbite.com/docs/) UI library in [ViewComponent](https://viewcomponent.org/). It only implements Flowbite's open source components.

Gustwave is built against Flowbite 3.x, currently 3.1.2. Its markup, classes and `data-*` attributes follow Flowbite's docs for that version.

Gustwave isn't published yet. It's used as a path gem and will move to its own repository once its API settles.

## Setup

Add the gem to your `Gemfile`:

```ruby
gem "gustwave", path: "gems/gustwave"
```

Import Gustwave's Tailwind CSS entry point in `app/assets/tailwind/application.css`, so that Tailwind CSS picks up the classes Gustwave uses. `bin/rails tailwindcss:build` creates the imported file:

```css
@import "../builds/tailwind/gustwave";
```

Flowbite itself is up to the host application, i.e. its Tailwind CSS plugin and its JavaScript. Use Flowbite 3.x: Gustwave's components rely on its JavaScript reading their `data-*` attributes, and other major versions aren't supported.

### Optional

- **Stimulus controllers:** Gustwave pins its controllers under `controllers/gustwave` in the importmap. Apps that eager load their controllers from `controllers` register them as `gustwave--*`, e.g. `gustwave--lexxy-heading`. `Gustwave::Modal` uses `gustwave--focus-trap`, plus `gustwave--undismissible-modal` when `dismissible: false`.
- **Action Text:** `Gustwave::RichText` renders Action Text content.
- **Previews:** Add Gustwave's ViewComponent previews in `config/application.rb`:

  ```ruby
  config.view_component.previews.paths << Gustwave::Engine.root.join("previews").to_s
  ```

## Options and styling

Components declare their options with the DSL in `Gustwave::Options`: `option`s, a value from a fixed list such as an HTML `tag`, and values `derive`d from them. They declare their Tailwind CSS classes with the DSL in `Gustwave::Styling`, which builds on it: a `base`, named `part`s, `variant`s such as `color` and `size`, and on/off `toggle`s. Variants and toggles are options with classes. Callers pick values with keyword arguments and add classes with `class:`, which win conflicts. Components that declare `unstyled color: :none` skip their base styles for `color: :none`, so callers can bring their own.

A keyword that is neither an option nor one of the component's own arguments is an HTML attribute of the component's element. A keyword named like an option is always the option, so pass the HTML attribute of that name in `html:`, which takes any attributes as a hash and wins over the flat ones: `Gustwave::Tabs.new(style: :underline, html: { style: "max-width: 40rem" })`. It works on slot setters that build an element too.

To restyle a component everywhere, extend it whenever it loads, e.g. in `config/initializers/gustwave.rb`. Subclasses that are already loaded pick up the change:

```ruby
Rails.autoloaders.main.on_load("Gustwave::Buttons::Default") do |button, _abspath|
  button.extend_variant :color, values: { brand: "text-white bg-brand-600 hover:bg-brand-700 focus:ring-brand-300" }
end
```

Some components let you swap the class they render, such as the menu of `Gustwave::Dropdown` with `list_menu_class`. Set it on a subclass, not on `Gustwave::Dropdown` itself. Setting it in `on_load` changes it for every dropdown in the process, tests included.

```ruby
class MyDropdown < Gustwave::Dropdown
  self.list_menu_class = "MyList"
end
```

`list_menu_class` is part of the extension API. See [Public API and stability](docs/design.md#public-api-and-stability).

### Cheat-sheet

| Declaration | Meaning | Example |
|---|---|---|
| `option` | A value from a fixed list, with a default | `option :tag, default: :h2, values: %i[h1 h2 h3]` |
| `derive` | A value derived per value of an option | `derive :icon_size, from: :size, values: { sm: :xs, md: :sm }` |
| `base` | Classes of the root element, or of parts given a hash | `base "inline-flex items-center"` |
| `part` | A named element besides the root, with optional classes | `part :icon, "h-3 w-auto"` |
| `unstyled` | Option values that skip the base styles | `unstyled color: :none` |
| `variant` | An option with classes per value | `variant :size, default: :md, values: { sm: "text-xs", md: "text-sm" }` |
| `toggle` | An on/off option with classes, off by default | `toggle :pill, "rounded-full"` |
| `on:` / `off:` | A toggle's classes for each state | `toggle :shadow, on: "shadow", off: "shadow-none"` |
| `per:` | A toggle's classes per value of another option; needs one for each value | `toggle :border, per: :color, values: { gray: "ring-gray-300", red: "ring-red-300" }` |
| `unless:` | Skip a declaration for some option values | `base "px-2", unless: { size: [:xs, :sm] }` |
| `part:` | Target a declared part instead of the root | `toggle :pill, "rounded-full", part: :icon` |
| `{ root:, icon: }` | Target several parts at once | `md: { root: "text-sm", icon: "h-3" }` |
| `internal: true` | The component selects the value itself, not callers | `toggle :visual_only, "p-2", internal: true` |
| `extend_option` / `extend_variant` / `extend_toggle` / `extend_derived` | Merge values into an inherited declaration | `extend_variant :color, values: { brand: "bg-brand-600" }` |
| `remove_option` / `remove_part` / `remove_variant` / `remove_toggle` / `remove_derived` | Delete an inherited declaration | `remove_toggle :pill` |

In the component, default keyword arguments to `DEFAULT`, pick values with `select_options`, read them with `option_value` and `derived_value`, and add the classes with `attributes_for`:

```ruby
class Badge < Gustwave::Component
  base     "inline-flex items-center rounded-sm"
  unstyled color: :none
  part     :icon, "h-3 w-auto"

  variant :color, default: :gray, values: { gray: "bg-gray-100 text-gray-800", red: "bg-red-100 text-red-800" }
  variant :size, default: :md, values: { sm: { root: "text-xs px-1.5", icon: "h-2.5" }, md: "text-sm px-2" }
  toggle  :pill, "rounded-full"
  toggle  :border, per: :color, values: { gray: "ring-1 ring-gray-300", red: "ring-1 ring-red-300" }
  toggle  :visual_only, "p-1", internal: true
  derive  :icon_size, from: :size, values: { sm: :xs, md: :sm }

  def initialize(text = nil, color: DEFAULT, size: DEFAULT, pill: false, border: false, **options)
    @text = text
    @options = options
    select_options(color:, size:, pill:, border:)
  end

  def before_render
    # Internal options first, then the classes, which depend on them
    select_options(visual_only: text_or_content(@text).blank?)
    @config = attributes_for(@options)
  end
end
```

See `Gustwave::Options` and `Gustwave::Styling` for every declaration and for subclassing.

Every option a component takes as a keyword argument, such as `tag`, `color` or `size`, is declared with this DSL and defaults to the declared default, so extending a component's default reaches every caller. `Gustwave::Component` documents the constructor convention, and the specs check every component against it.

### Buttons

Each button theme is a class in `Gustwave::Buttons`. Instantiate it directly when the theme is fixed in code. Use `Gustwave::Button.for(theme)` when the theme comes from data or options, which returns the theme's class:

```ruby
render Gustwave::Buttons::GradientDuotone.new("Sign in")
render Gustwave::Button.for(theme).new("Sign in")
```

### Strictness

In development and test, an unknown option, value, part or theme raises an error that names the valid ones. For an option named like an HTML attribute, such as `size`, the error says how to pass the attribute: `html: { size: 20 }`. In every other environment, the component falls back instead, e.g. to the option's default. Set `config.gustwave.strict` to choose, e.g. to raise in staging, or in a CI environment that doesn't run as `test`:

```ruby
# config/environments/staging.rb
config.gustwave.strict = true
```

## Building forms

Gustwave's form components come in layers. They give you fine-grained control when you need it, and full convenience when you're happy with the defaults:

* A **control** renders the bare form element, e.g. an input field, in Flowbite's look.
* Give the **control** an attribute and any Rails form builder, and it renders through Rails' form helpers.
* **Fields** add a label, an optional helper text and an error or success message to the control. They take care of wiring up the elements and come in two flavors: stacked (`Gustwave::Form::Field`) and inline (`Gustwave::Form::InlineField`).
* **Groups** wrap the controls that set one shared attribute, e.g. the radio buttons of a choice or the checkboxes of a multiple choice, in a `<fieldset>` with a legend and a single error message (`Gustwave::Form::Fieldset`).
* The **form builder** `Gustwave::FormBuilder` renders all of the above through Rails' form helpers you already know, like `f.text_field` and `f.check_box`.
* Make the **form builder the default** of a controller, and its forms use Gustwave without asking for it.

Start with the highest layer that fits, and step down wherever you need more control.

### Controls

By default, a control renders one form element in Flowbite's look. On its own, a control is a plain element: you pass `name`, `id` and `value` as HTML attributes, just like with `tag.input`.

Typical use-cases are:

* Plain controls for elements that aren't part of a model's form, like a search box or a checkbox in each row of a table:

    ```erb
    <%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) %>
    # => <input type="search" name="q" aria-label="Search" class="…">
    
    <%= render Gustwave::Form::Checkbox.new(name: "task_ids[]", value: 7, aria: { label: "Select    task" }) %>
    # => <input type="checkbox" name="task_ids[]" value="7" aria-label="Select task" class="…">
    ```

* Building blocks in your own components:

    ```ruby
    class SearchBoxComponent < ViewComponent::Base
    def initialize(query: nil)
        @query = query
    end
    
    def call
        form_with url: tasks_path, method: :get, role: "search" do
          render Gustwave::Form::Input.new(
            type: :search, name: "q", value: @query, icon: :search,
            placeholder: "Search tasks", aria: { label: "Search tasks" }
          )
        end
    end
    end
    ```
  
#### Binding controls to a form builder

When you pass the `attribute` and `form:` parameters to a control, e.g. `<%= render Gustwave::Form::Input.new(:title, form: f, ...) %>`, it renders through any Rails form builder. So the ID, name and value come from the record, and nested attributes, `index` and `namespace` work just like in any other Rails form. Checkboxes bring along their hidden field that sends the unchecked value:

```erb
<%= form_with model: @task do |f| %>
  <%= render Gustwave::Form::Input.new(:title, form: f, aria: { label: "Title" }) %>
  # => <input type="text" name="task[title]" id="task_title" value="Write the README" aria-label="Title" class="…">

  <%= render Gustwave::Form::Checkbox.new(:archived, form: f, aria: { label: "Archived" }) %>
  # => <input type="hidden" name="task[archived]" value="0">
  #    <input type="checkbox" name="task[archived]" id="task_archived" value="1" aria-label="Archived" class="…">
<% end %>
```

> [!NOTE]
> Rails' `field_error_proc` never wraps a control, because its `<div class="field_with_errors">` would break the markup. Instead, a bound control switches to `validation: :error` by itself while its attribute has errors. That adds `aria-invalid="true"` and, on controls that have one, the error look. It doesn't add a message, because the message belongs to the field. Pass `validation: :none` if you don't want it.

#### Built in controls

Gustwave has the following controls built in:

| Component | Renders |
|---|---|
| `Gustwave::Form::Input` | A single-line input field, e.g. for text, an email address or a date |
| `Gustwave::Form::Textarea` | A multi-line text field |
| `Gustwave::Form::RichTextarea` | A rich text editor, Lexxy or Trix, in a frame with its toolbar |
| `Gustwave::Form::FileInput` | A file input that picks files to upload |
| `Gustwave::Form::Select` | A drop-down list, or with `multiple` a list box |
| `Gustwave::Form::Toggle` | A checkbox shown as a switch, for a yes or no answer |
| `Gustwave::Form::Checkbox` | A checkbox, for a yes or no answer or one of several options |
| `Gustwave::Form::Radio` | A radio button, for one choice out of several |
| `Gustwave::Form::InputGroup` | An input or a select with a text, a button or a dropdown attached beside it |

> [!NOTE] 
> A control has no visible label, so make sure to give it an accessible name, e.g. with `aria: { label: … }`.

### Fields

A field renders a control together with its label, helper text and validation message. It takes care of wiring them up, too. The label's `for`, the control's `aria-describedby` and `aria-invalid`, and the colors of the validation state. 

Gustwave comes with two field layout types out of the box:
* `Gustwave::Form::Field` stacks the elements vertically. 
* `Gustwave::Form::InlineField` puts the label next to the control, which is what you want for a toggle, a checkbox or a radio button. Bound to an attribute, a field takes its label from Rails' `label` helper and shows the attribute's errors.

You usually get fields from the form builder. Render one yourself in a form with a different builder, or when the builder's shorthand isn't enough, e.g. for a label with a link in it or for your own markup as the control:

```erb
<%= render Gustwave::Form::Field.new(:title, form: f, helper_text: "Shown in the task list.") do |field| %>
  <% field.with_control_input(size: :lg) %>
<% end %>
# => <div>
#      <label for="task_title" class="…">Title</label>
#      <input type="text" name="task[title]" id="task_title" value="Write the README" aria-describedby="task_title_helper_text" class="…">
#      <p id="task_title_helper_text" class="…">Shown in the task list.</p>
#    </div>

<%= render Gustwave::Form::InlineField.new(:terms, form: f) do |field| %>
  <% field.with_control_checkbox %>
  <% field.with_label { "I accept the #{link_to("terms", terms_path)}.".html_safe } %>
<% end %>
# => <div>
#      <div class="flex">
#        <div class="flex items-center h-5">
#          <input type="hidden" name="task[terms]" value="0">
#          <input type="checkbox" name="task[terms]" id="task_terms" value="1" class="…">
#        </div>
#        <div class="text-sm ms-2">
#          <label for="task_terms" class="…">I accept the <a href="/terms">terms</a>.</label>
#        </div>
#      </div>
#    </div>
```

When the attribute has errors, the control is in the error state (`aria-invalid="true"` and, on an input, the red classes), and the field adds the rest: it colors the label red and renders the error messages below the control: `<p id="task_title_validation_message" class="…">Can't be blank</p>`. `validation: :none` on the field turns off the error colors and `aria-invalid`, on the control too. The message is still rendered.

### Groups

A group renders the controls that set one shared attribute together, e.g. the radio buttons of a choice or the checkboxes of a `multiple` attribute. Each control keeps its own field and error state, but the group shows the error message once.

You have two ways to render a group:
* `Gustwave::Form::Fieldset` wraps the fields in a `<fieldset>` with a `<legend>`, an optional helper text and the error message, each shown once.
* `Gustwave::Form::ValidationMessage` renders just the message, for when you'd rather write the `<fieldset>` yourself. Then wiring up the message is up to you, too:

    ```erb
    <fieldset aria-describedby="<%= f.field_id(:plan, :validation_message) %>">
      <legend>Plan</legend>
      <%# … one InlineField per radio button … %>
      <%= render Gustwave::Form::ValidationMessage.new(:plan, form: f) %>
      # => <p id="task_plan_validation_message" class="…">Can't be blank</p>
    </fieldset>
    ```

You usually get a fieldset from the form builder's `f.fieldset`. Render one yourself in a form with a different builder:

```erb
<%= render Gustwave::Form::Fieldset.new(:plan, form: f, label: "Plan") do %>
  <%= render Gustwave::Form::InlineField.new(:plan, form: f) do |field| %>
    <% field.with_control_radio(value: "free") %>
  <% end %>
  <%= render Gustwave::Form::InlineField.new(:plan, form: f) do |field| %>
    <% field.with_control_radio(value: "pro") %>
  <% end %>
<% end %>
# => <fieldset>
#      <legend class="…">Plan</legend>
#      <div>… <input type="radio" name="task[plan]" id="task_plan_free" value="free" checked class="…"> … <label for="task_plan_free">Free</label> …</div>
#      <div>… <input type="radio" name="task[plan]" id="task_plan_pro" value="pro" class="…"> … <label for="task_plan_pro">Pro</label> …</div>
#    </fieldset>
```

### Form builder

The form builder renders a whole field (label, control, helper text and error message) from a single Rails form helper call. It keeps Rails' helper names and arguments, so to switch an existing form over, add `builder: Gustwave::FormBuilder` and you're done:

```erb
<%= form_with model: @task, builder: Gustwave::FormBuilder do |f| %>
  <%= f.text_field :title, helper_text: "Shown in the task list." %>
  # => the <div> of the Field example above, with the default size
  <%= f.email_field :contact, icon: :envelope, size: :lg %>
  <%= f.select :country, @countries, prompt: "Choose a country" %>
  <%= f.toggle :published, color: :green %>
  <%= f.fieldset :plan, label: "Plan" do %>
    <%= f.radio_button :plan, "free" %>
    <%= f.radio_button :plan, "pro" %>
  <% end %>
<% end %>
```

On top of Rails' arguments, a helper takes:
* The field's options: `label`, `helper_text`, `validation` and `validation_message`.
* The control's options, like `size` and `icon`. If an HTML attribute has the same name as an option, pass it in `html:`, e.g. `html: { size: 20 }`.
* A block, which gets the field, so you can set its slots.

A few things work differently from Rails:
* `f.check_box`, `f.radio_button` and `f.toggle` render their own label, so you don't need an `f.label` next to them.
* Helpers that have no Gustwave control, like `hidden_field`, stay as Rails renders them.

See `Gustwave::FormBuilder` for every helper. Want your own controls or field classes? Subclass the builder, as its docs show.

### Make `Gustwave::FormBuilder` the default

You can use [Rails' `default_form_builder`](https://api.rubyonrails.org/classes/ActionController/FormBuilder/ClassMethods.html#method-i-default_form_builder) to make `Gustwave::FormBuilder` the default form builder of a controller and its subclasses. Then their forms don't need `builder: Gustwave::FormBuilder` anymore:

```ruby
class ApplicationController < ActionController::Base
  default_form_builder Gustwave::FormBuilder
end
```

> [!WARNING]
> Gems like Devise have controllers that inherit from your `ApplicationController`, so setting the default there restyles their forms too. To leave them alone, set it on a base controller of your own instead. A single form can opt out with `builder: ActionView::Helpers::FormBuilder`.

For the reasoning behind the layers, see [Forms in the design notes](docs/design.md#forms).

## Component status

Every component has a status that says how much its API may change:

- **Alpha:** may change in any minor release. Every change comes with an upgrade note.
- **Beta:** the API has settled. Anything removed is deprecated one minor release first.
- **Stable:** like beta while Gustwave is at 0.x. From 1.0, removals only come in a major release.
- **Deprecated:** logs a warning and is removed in the next minor release.

Patch releases only contain fixes. A component's class documentation names its status in a `@status` tag, and Lookbook shows it in the Status panel. Every component is alpha for now. When a component moves up, and when it's ready to, is described under [Component lifecycle](docs/design.md#component-lifecycle).

## Development

The specs run against a minimal Rails application in `spec/dummy`. Run `bundle exec rspec` in the gem's directory.

### Designing components

Read [docs/design.md](docs/design.md) before you add a component or change a component's API. It decides how a Flowbite pattern is split into components, options, slots and block content, which conventions recurring parts follow, and how components move from alpha to stable. Lookbook shows it under "Component design". [AGENTS.md](AGENTS.md) sums it up for coding agents, and the [extract-flowbite-component skill](.claude/skills/extract-flowbite-component/SKILL.md) walks them through turning a Flowbite pattern into a component.

`Gustwave::Test::StyleSnapshots` records the markup a component renders for every combination of its style options and compares it to a YAML fixture. It helps when building a component or changing one's styles; see its documentation for usage.

The API snapshots in `spec/fixtures/api_snapshots` record each component's public and extension API, so every API change shows up in review. Run `UPDATE_API_SNAPSHOTS=1 bundle exec rspec spec/components/api_snapshot_spec.rb` to record an intended change. `spec/components/conventions_spec.rb` checks the conventions of [docs/design.md](docs/design.md#enforcement).

### API docs

The classes and methods are documented with [YARD](https://yardoc.org). Run `bundle exec yard` in the gem's directory to build the docs into `doc/`, or `bundle exec yard server --reload` to browse them while you edit. `.yardopts` sets what they include, and `bundle exec yard stats --list-undoc` lists what they show without a docstring.

### Previewing components

Start the host application in development and open `/lookbook` to browse every preview with its source, notes and params. Set the `theme` display option to `dark` to check the `dark:` variants.

Lookbook belongs to the host application in this repository and isn't a dependency of the gem, so previews stay plain `ViewComponent::Preview` classes. `/rails/view_components` keeps working without it.

### Importing icons

`bin/import-icon` copies [Flowbite icons](https://github.com/themesberg/flowbite-icons) into `app/assets/images/gustwave/icons` and converts them to Gustwave's form. Set `GITHUB_TOKEN` (or log in with `gh`) to avoid GitHub's rate limit.

The source is pinned to a Flowbite release tag (`DEFAULT_SOURCE` in `script/icon_import.rb`), so the icons stay the same until the tag is bumped.

```sh
bin/import-icon chalkboard-user                    # bare name, outline theme
bin/import-icon solid/info-circle --as info        # THEME/CATEGORY/NAME path, renamed; --force overwrites
bin/import-icon https://github.com/themesberg/flowbite-icons/blob/main/src/outline/education/chalkboard-user.svg
bin/import-icon --new --dry-run                    # list upstream icons that are not local yet
bin/import-icon --new                              # ... and import them
bin/import-icon --new --theme solid --category arrows --only "arrow-*"  # narrow the import with filters
bin/import-icon --reimport --dry-run               # compare every local icon with upstream
bin/import-icon --reimport                         # ... and update the ones that differ
bin/import-icon --check                            # offline: verify local icons follow the conventions
```

`--new` imports every upstream icon that is not local yet. `--theme` limits it to one theme (default: both), `--category` to one upstream folder (exact name, such as `arrows` or `food:beverage`), and `--only` to names matching a glob. It keeps going after a failed icon and exits 1 if any failed.

`EXCLUDED` in `script/icon_import.rb` lists upstream icons that are deliberately not imported. `--new` and `--reimport` skip them. `outline/spinner.svg` and the `outline/chevron-*-compact.svg` icons are custom, listed in `LOCAL_ONLY`, and skipped by `--reimport` and `--check`. The compact chevrons have no padding around their artwork, so always give them a size class, e.g. `class: "h-2.5 w-2.5"`.

To upgrade Flowbite, bump the tag in `DEFAULT_SOURCE`, then run `bin/import-icon --reimport --dry-run` to review changes to existing icons and `bin/import-icon --new --dry-run` to review the new ones. Run them for real once the output looks right, and commit the result.

`--source URL` imports from another GitHub tree URL.

### Flowbite coverage

`lookbook/flowbite.yml` lists every example in Flowbite's docs and how far Gustwave covers it. `previewed` means a scenario demonstrates it, `composable` that existing components could build it, and `tailwind` that it needs plain Tailwind classes only. `feature_gap`, `partial` and `blocked` say what's missing in `needs`, and `out_of_scope` marks the third-party plugin pages. Lookbook shows it at `/lookbook/pages`, with one page per Flowbite docs page. The importer generates those pages into `lookbook/pages/flowbite`, so don't edit them by hand. None of this is shipped with the gem.

To upgrade Flowbite, bump the tag in `DEFAULT_SOURCE` in `script/flowbite_inventory.rb`, run `bin/flowbite-inventory --dry-run` to review the changes, then run it for real and classify what it added. The specs fail until every example has a status.

## License

Gustwave is released under the [MIT License](LICENSE.txt). It implements [Flowbite](https://flowbite.com/docs/getting-started/license/)'s open source components and ships Flowbite's icons, both also under the MIT License.
