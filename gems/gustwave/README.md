# Gustwave

Gustwave is an unofficial implementation of the [Flowbite](https://flowbite.com/docs/) UI library in [ViewComponent](https://viewcomponent.org/). It only implements Flowbite's open source components.

Gustwave is developed inside Tendril Tasks as a path gem and will move to its own repository once its API settles.

## Setup

Add the gem to your `Gemfile`:

```ruby
gem "gustwave", path: "gems/gustwave"
```

Import Gustwave's Tailwind CSS entry point in `app/assets/tailwind/application.css`, so that Tailwind CSS picks up the classes Gustwave uses. `bin/rails tailwindcss:build` creates the imported file:

```css
@import "../builds/tailwind/gustwave";
```

Flowbite itself is up to the host application, i.e. its Tailwind CSS plugin and its JavaScript.

### Optional

- **Stimulus controllers:** Gustwave pins its controllers under `controllers/gustwave` in the importmap. Apps that eager load their controllers from `controllers` register them as `gustwave--*`, e.g. `gustwave--lexxy-heading`. `Gustwave::Modal` uses `gustwave--focus-trap`, plus `gustwave--undismissible-modal` when `dismissible: false`.
- **Action Text:** `Gustwave::RichText` renders Action Text content.
- **Previews:** Add Gustwave's ViewComponent previews in `config/application.rb`:

  ```ruby
  config.view_component.previews.paths << Gustwave::Engine.root.join("previews").to_s
  ```

## Options and styling

Components declare their options with the DSL in `Gustwave::Options`: `option`s, a value from a fixed list such as an HTML `tag`, and values `derive`d from them. They declare their Tailwind CSS classes with the DSL in `Gustwave::Styling`, which builds on it: a `base`, named `part`s, `variant`s such as `color` and `size`, and on/off `toggle`s. Variants and toggles are options with classes. Callers pick values with keyword arguments and add classes with `class:`, which win conflicts. Components that declare `unstyled color: :none` skip their base styles for `color: :none`, so callers can bring their own.

To restyle a component everywhere, extend it whenever it loads, e.g. in `config/initializers/gustwave.rb`. Subclasses that are already loaded pick up the change:

```ruby
Rails.autoloaders.main.on_load("Gustwave::Buttons::Default") do |button, _abspath|
  button.extend_variant :color, values: { brand: "text-white bg-brand-600 hover:bg-brand-700 focus:ring-brand-300" }
end
```

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

In development and test, an unknown option, value, part or theme raises an error that names the valid ones. In every other environment, the component falls back instead, e.g. to the option's default. Set `config.gustwave.strict` to choose, e.g. to raise in staging, or in a CI environment that doesn't run as `test`:

```ruby
# config/environments/staging.rb
config.gustwave.strict = true
```

## Development

The specs run against a minimal Rails application in `spec/dummy`. From the Tendril Tasks root, run `mise run test:gustwave`, or `bundle exec rspec` in `gems/gustwave`.

`Gustwave::Test::StyleSnapshots` records the markup a component renders for every combination of its style options and compares it to a YAML fixture. It helps when building a component or changing one's styles; see its documentation for usage.

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

`EXCLUDED` in `script/icon_import.rb` lists upstream icons that are deliberately not imported. `--new` and `--reimport` skip them. `outline/spinner.svg` is a custom icon, listed in `LOCAL_ONLY`, and is skipped by `--reimport` and `--check`.

To upgrade Flowbite, bump the tag in `DEFAULT_SOURCE`, then run `bin/import-icon --reimport --dry-run` to review changes to existing icons and `bin/import-icon --new --dry-run` to review the new ones. Run them for real once the output looks right, and commit the result.

`--source URL` imports from another GitHub tree URL.

## License

Gustwave is released under the [MIT License](LICENSE.txt). It implements [Flowbite](https://flowbite.com/docs/getting-started/license/)'s open source components and ships Flowbite's icons, both also under the MIT License.
