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

- **Stimulus controllers:** Gustwave pins its controllers under `controllers/gustwave` in the importmap. Apps that eager load their controllers from `controllers` register them as `gustwave--*`, e.g. `gustwave--lexxy-heading`.
- **Action Text:** `Gustwave::RichText` renders Action Text content.
- **Previews:** Add Gustwave's ViewComponent previews in `config/application.rb`:

  ```ruby
  config.view_component.previews.paths << Gustwave::Engine.root.join("previews").to_s
  ```

## Styling

Components declare their Tailwind CSS classes with the DSL in `Gustwave::Styling`: a `base`, named `part`s, `variant`s such as `scheme` and `size`, and on/off `toggle`s. Callers pick values with keyword arguments and add classes with `class:`, which win conflicts.

To restyle a component everywhere, extend it whenever it loads, e.g. in `config/initializers/gustwave.rb`. Subclasses that are already loaded pick up the change:

```ruby
Rails.autoloaders.main.on_load("Gustwave::Buttons::Default") do |button, _abspath|
  button.extend_variant :scheme, values: { brand: "text-white bg-brand-600 hover:bg-brand-700 focus:ring-brand-300" }
end
```

See `Gustwave::Styling` for every declaration and for subclassing.

## Development

The specs run against a minimal Rails application in `spec/dummy`. From the Tendril Tasks root, run `mise run test:rspec:gustwave`, or `bundle exec rspec` in `gems/gustwave`.

`Gustwave::Test::StyleSnapshots` records the markup a component renders for every combination of its style options and compares it to a YAML fixture. It helps when building a component or changing one's styles; see its documentation for usage.

## License

Gustwave is released under the [MIT License](LICENSE.txt). It implements [Flowbite](https://flowbite.com/docs/getting-started/license/)'s open source components and ships Flowbite's icons, both also under the MIT License.
