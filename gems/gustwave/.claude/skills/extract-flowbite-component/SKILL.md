---
name: extract-flowbite-component
description: Turn a Flowbite UI pattern into Gustwave ViewComponents, end to end, from reading Flowbite's docs to previews, coverage and specs. Use when adding a Gustwave component for a Flowbite pattern (accordion, stepper, sidebar…), covering more of a Flowbite page's examples with an existing component, or unblocking examples that lookbook/flowbite.yml marks as needing a component.
---

# Extract a Flowbite pattern into Gustwave

Paths are relative to the gem's root. `docs/design.md` decides how to slice the pattern; this skill is the order of work around it. Read `docs/design.md` in full before step 2, and `AGENTS.md` if you haven't.

## 1. Find the pattern

1. Find the Flowbite docs page in `lookbook/flowbite.yml`, e.g. `components/accordion`, and note every example on it with its status.
2. Find examples on other pages that wait for this pattern: `rg -n "needs: accordion" lookbook/flowbite.yml`.
3. Read each example's markup in Flowbite's source at the pinned version: `content/<page>.md` in `themesberg/flowbite` at tag `v<flowbite_version>`, with the version from the top of `lookbook/flowbite.yml`. `Gustwave::FlowbiteCoverage#source_url` builds the link. Take markup, classes and `data-*` attributes from there, never from memory or another version.
4. Note which existing components already render parts of it: `Icon`, `Buttons::*`, `Heading`, `Paragraph`, `Badge`, `Avatar`. Reuse them.

## 2. Slice it

Compare all examples on the page, not just the first. For each piece of markup, decide with `docs/design.md`:

- **The invariant**, which the component owns: classes, nesting, ARIA and the JavaScript wiring that break if a caller gets them wrong.
- **Fixed choices**, like colors or sizes: `option`, `variant` or `toggle`.
- **Parts the component has to place or wire**: slots. Recurring parts take their canonical shape from "Recurring sub-patterns": dismiss and close buttons, visuals, `<part>_options:`, triggers, sections, IDs.
- **Everything else**: the content block. An example that only rearranges existing components is `composable`, not a reason for a slot.
- **Separate components** only by the four criteria in "When a piece becomes a component". Promote, don't predict.

Write the proposal down: class names; each constructor; options with their values and defaults; slots with their types; parts; and for every Flowbite example, whether it becomes a preview, is composable or Tailwind-only, or still needs something.

**When working with a person, show them the proposal and wait for approval before writing code.** If a rule in `docs/design.md` doesn't fit, say so and ask. Don't work around it, and don't invent a new shape for something it covers.

## 3. Build

- One class per file under `app/components/gustwave/`, inheriting from `Gustwave::Component` and named after the Flowbite pattern, without a `Component` suffix.
- Follow the constructor convention in `app/components/gustwave/component.rb`. Declare the classes with the Options and Styling DSL (README, "Options and styling"), copied from Flowbite's markup.
- Declare slots with `renders_one_extensible` or `renders_many_extensible`. Give polymorphic slots a `generic` or `renderable` escape hatch.
- The parent generates IDs and passes `aria-*` and `data-*` attributes to the slots it builds. A standalone sub-component requires its parent's ID as `<parent>_id:`.
- Text the component renders itself, like screen reader labels, goes into a sidecar `<name>.yml` with the same locales as the existing ones.
- Rely on Flowbite's JavaScript reading the `data-*` attributes. Add a Stimulus controller under `app/javascript/controllers/gustwave/` only for behavior Flowbite doesn't cover, and have the component wire it up itself.
- End every new class's docstring, nested and base classes included, with `# @status alpha`. Document each slot with an example.

## 4. Preview

- `previews/gustwave/<name>_preview.rb`, named after the component, so Lookbook's Status panel finds it. Add one scenario per Flowbite example where possible, using `render_with_template` with templates in `previews/gustwave/<name>_preview/<scenario>.html.erb`.
- The comment above a scenario is its note in Lookbook. Say in plain words what it shows.
- Add a playground scenario with `@param` tags when the options interact.

## 5. Record coverage

In `lookbook/flowbite.yml`:

- Give each example of the page its status. A `previewed` example points to its scenario: `preview: gustwave/<name>/<scenario>`.
- `partial`, `feature_gap` and `blocked` examples say what they still need in `needs:`, and `note:` explains a deliberate difference from Flowbite.
- Reclassify the examples on other pages that needed this pattern.

Don't edit `lookbook/pages/flowbite/`; it's generated.

## 6. Specs

- `spec/components/gustwave/<name>_spec.rb`: `render_inline` each component and assert on the rendered output: classes, attributes, ARIA, slots, and the block.
- `spec/components/gustwave/style_snapshots_<name>_spec.rb`: a style snapshot with groups for options that affect each other (see `Gustwave::Test::StyleSnapshots`). Write it with `UPDATE_STYLE_SNAPSHOTS=1`, then read the fixture.
- Record the API with `UPDATE_API_SNAPSHOTS=1 bundle exec rspec spec/components/api_snapshot_spec.rb`, then read the fixture as the API you're committing to.
- The constructor convention, status and conventions specs pick up new components on their own. Add a constructor convention `setups` entry only when the component can't be built without arguments. Never add a new component to the conventions spec's known violations or exceptions.

## 7. Check

- `bundle exec rspec` and `bundle exec rubocop`, both in the gem's root.
- If you can run the host application, open the previews in Lookbook and compare them with Flowbite's examples in light and dark mode.

Then report:
- the components and their API;
- each Flowbite example's coverage status;
- any judgement call `docs/design.md` didn't settle, proposed as a new entry under its Decisions.

## Changing an existing component

To cover more examples with an existing component, follow the same steps. Before changing its API, check its `@status`. Alpha changes need an upgrade note. In beta and stable, removing or renaming anything needs a deprecation one minor release first. The API snapshot spec's failure message says which applies.
