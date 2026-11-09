# Gustwave

Gustwave implements Flowbite's open source UI components as ViewComponents for Rails. `README.md` documents how to use it. `docs/design.md` documents how components are designed.

Gustwave is built against Flowbite 3.x. `lookbook/flowbite.yml` pins the exact docs version, currently 3.1.2. Take markup, classes and `data-*` attributes from Flowbite's docs at that version, not from memory or another version.

## Before changing a component

Read `docs/design.md` before you add a component or change a component's API: its keywords, options, slots, parts or extension points. It decides how a Flowbite pattern is split into components, options, slots and block content. Don't invent a new shape for something it already covers.

The short version:

- Options for fixed choices, slots for parts the component has to place or wire, the content block for everything else. A new slot or option needs a reason from `docs/design.md`; when in doubt, leave it to the block.
- No `Component` suffix: `Gustwave::Card`.
- Every new component, nested and base classes included, gets `# @status alpha` as the last line of its class docstring. `spec/components/component_status_spec.rb` checks it. Don't change a status unless asked; promotions follow `docs/design.md`.
- Style a part with `<part>_options:`. Never add `configure_<part>` or `<part>_class:` for an element. `<state>_class:` is only for classes a script swaps.
- `dismiss_button` slot for elements that go away for good, `close_button` slot for overlays that reopen.
- `Gustwave::Visuals` for visuals: `leading_visuals` and `trailing_visuals` inline with text, `visuals` for visuals the component places. All three are many, with every type. A slot named after its role only for a visual that carries meaning or isn't an icon, image or SVG, like Alert's `icon` or Timeline's `marker`, and a slot per state for a visual per state, like Clipboard's `icon` and `copied_icon`. `icon:` keywords are shorthand for a slot, never the only way.
- Flowbite's hover or click trigger setting is `trigger_event:`. Triggers rendered elsewhere use `trigger_options(...)`.
- A standalone sub-component requires its parent's ID as `<parent>_id:`.
- Follow the constructor convention in `app/components/gustwave/component.rb`.
- A breaking change to a beta or stable component needs a deprecation one minor release before the removal.

To turn a Flowbite pattern into a component, or to cover more of a Flowbite page with an existing one, follow the `extract-flowbite-component` skill in `.claude/skills/`.

If a rule doesn't fit your case, stop and ask rather than working around it. A change to a rule belongs in `docs/design.md`, and a settled question gets a new entry under its Decisions.

## Layout

- `app/components/gustwave/`: components. `app/components/concerns/gustwave/`: the Options, Styling, ExtensibleSlots and Visuals concerns.
- `previews/gustwave/`: ViewComponent previews, one scenario per Flowbite example where possible.
- `lookbook/flowbite.yml`: every Flowbite docs example and how far Gustwave covers it. A spec fails until every example has a coverage status.
- `lookbook/component_status.rb`: reads each component's `@status` tag, for the status spec and Lookbook's Status panel. Like `lookbook/flowbite.yml`, it isn't shipped with the gem.
- `spec/`: specs, run against the Rails app in `spec/dummy`. `spec/fixtures/style_snapshots/` holds the class snapshots.
- `script/`, `bin/`: the icon importer and the Flowbite inventory.

## Checking changes

Run from this directory:

- `bundle exec rspec` for all specs, or `bundle exec rspec spec/components/gustwave/card_spec.rb` for one file.
- `bundle exec rubocop` for lint.

When a change to a component's classes is intended, update its style snapshot as described in `Gustwave::Test::StyleSnapshots`.

When a change to a component's API is intended, first check its `@status` for whether the change needs a deprecation, then record it with `UPDATE_API_SNAPSHOTS=1 bundle exec rspec spec/components/api_snapshot_spec.rb`. Never update a snapshot just to make the spec pass.

When `spec/components/conventions_spec.rb` fails, follow the rule its message names. Don't add a known violation or an exception to make it pass. Remove a known violation once you've fixed it. A new or changed Flowbite example needs its status in `lookbook/flowbite.yml`.
