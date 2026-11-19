# Component design

How Gustwave slices a Flowbite UI pattern into ViewComponents, options, slots and block content, and the conventions every component follows. It's for anyone adding a component or changing a component's API, human or agent.

A caller who knows one Gustwave component should be able to predict the API of the next one. Two maintainers extracting the same Flowbite pattern should arrive at the same slicing.

Gustwave is built against Flowbite 3.x. A "Flowbite example" here means an example in Flowbite's docs at the version pinned in `lookbook/flowbite.yml`, currently 3.1.2. Take markup, classes and `data-*` attributes from those docs, not from another Flowbite version.

The styling DSL (`Gustwave::Options`, `Gustwave::Styling`) is documented in the README, and the constructor convention in `Gustwave::Component`. Specs already enforce both. This document builds on them and doesn't repeat them.

**How to apply it.** The rules apply to every new component and to every change to an existing component's API. Some existing components don't follow them yet; that work is tracked in issues labelled `gustwave-design`. Mechanisms marked *planned* don't exist yet. Follow the rule anyway and don't wait for the mechanism. Past decisions, with their reasons, are listed under [Decisions](#decisions).

## The core rule

A Flowbite example is a tree of markup, and a component boundary could go at almost any node. Don't slice the DOM. Slice by the decisions a caller makes.

A component owns its **invariant**: the classes, nesting, ARIA and JavaScript wiring that break if a caller gets them wrong. Everything a caller **chooses** is exposed in the lightest mechanism that can express the choice:

| The caller chooses | Expose it as | Example |
|---|---|---|
| A value from a fixed list | `option`, `variant` or `toggle` | `size`, `color`, `horizontal` |
| Whether a known part appears | A slot | `Card#with_image`, `Banner#with_dismiss_button` |
| Which kind of a known part appears | A polymorphic slot | `with_item_link` / `with_item_generic` |
| Anything else | The content block, composed from other components | Card body, Timeline item body |

## When a piece becomes a component

A piece of markup gets its own component class when at least one of these holds:

1. **It has its own invariant.** Markup that's easy to get subtly wrong, such as a modal header's close button and label, or a dropdown trigger's `data-dropdown-*` attributes. Hard-coded classes alone don't count.
2. **Callers need it outside its parent's slot.** `ModalBody` and `ModalFooter` exist because a `form_with` has to wrap them. Table rows and cells exist because callers render them in loops.
3. **It appears in more than one pattern.** `Icon`, `Avatar`, `Badge`, `Heading`, `Paragraph`, `Buttons::*`.
4. **It belongs to a family of interchangeable variations.** See [Variation](#variation).

Otherwise it stays inside its parent as a declared `part`, styled through `<part>_options:` (see [Styling a part](#styling-a-part)).

Name a component after its Flowbite pattern, without a `Component` suffix: `Gustwave::Card`, not `Gustwave::CardComponent` (D2).

## Slot or content block

Use a slot only when the parent has to know about the child:

- **Position.** It goes somewhere the block can't reach: Card's image above the padded body, a timeline marker on the line.
- **Mutual influence.** The parent changes because the child exists (`has_image` pads Card's body less; Navbar shows the hamburger only with items or a menu header), or passes something down (`apply_slot_context` in ButtonGroup and Pagination).
- **Wiring.** Parent and child share an ID or behavior: the Banner `id` its dismiss button targets, a modal header's label.

If the parent doesn't need to know, the piece belongs in the content block. When a Flowbite example only rearranges existing components, it's `composable` in `lookbook/flowbite.yml`, not a reason for a new slot.

**Promote, don't predict.** A composition repeated at three or more call sites becomes a component. A component that always needs a specific child becomes a slot. A new slot or option is hard to remove; block content costs nothing to add later.

Every polymorphic slot keeps an escape hatch: a `generic` type that takes a block, or a `renderable` type that takes any component.

**A slot's block reaches the component it builds.** When a slot builds a component, the block given to its setter becomes that component's content block, and the block receives the component, as `render` does (D6). So callers reach a sub-component's own slots through the parent, without the parent forwarding them:

```ruby
render Gustwave::Modal.new do |modal|
  modal.with_header("Delete task") { |header| header.with_close_button(text: "Close dialog") }
end
```

For this to hold:

- **The block is also the content.** Without a text argument, its output is the component's content. In ERB, a block that only configures leaves whitespace, so pass the text as an argument.
- **Read slots through their getter or predicate** (`close_button`, `icon?`), at render time. Both evaluate the block first. A decision made in `initialize`, or from an instance variable, can't see what the block sets.
- **A wrapper that delegates slots to an inner component** (`delegate_missing_to`, as `Dropdowns::Triggers::Button` and `DismissButton` do) calls `content` before reading the inner component's slots, since the inner component's getters don't evaluate the wrapper's block.
- It doesn't apply to slots that build markup instead of a component, like Alert's `icon`.

## Variation

Variation between similar components takes one of four shapes:

- **A separate class** when the variation changes the markup structure, the constructor, or the set of option values. Each button theme has its own color palette, which the Options DSL can't express as one `variant`, so `Buttons::GradientDuotone` is its own class. Dropdown triggers and menus differ in structure.
- **A variant** when it only picks classes from within one option set: Badge and Alert colors.
- **A wrapper component** (composition) when it presets another component: `AvatarText` and `AvatarPlaceholder` render `Avatar`. This is also the recommended way for an app to name a theme, e.g. a `Ui::Button` that renders `Gustwave::Buttons::GradientDuotone`.
- **A slot** when it adds an optional sub-part to otherwise identical markup. By this rule, `IconToast` should be `Toast` with a `visuals` slot, not a separate class.

## Recurring sub-patterns

These parts show up across many Flowbite patterns. Each has one shape, so callers learn it once.

### Dismiss and close buttons

Two behaviors, two names, one shape:

- **`dismiss_button`** removes an element from the page for good, through `Gustwave::DismissButton` and `data-dismiss-target`. Alert, Banner, Badge, Toast.
- **`close_button`** hides an overlay that can open again, through Flowbite's `data-modal-hide` or `data-drawer-hide`. Modal and Drawer headers.

Both are `renders_one_extensible` slots. Where Flowbite's examples always show the button, the component renders it by default through ViewComponent's `default_<slot>`. A `dismissible:` keyword means "the user can dismiss or close this". With `dismissible: false` the button isn't rendered and, for overlays, the backdrop and Escape don't close it, as `Modal` already does.

```ruby
render Gustwave::Toast.new("Saved.")                      # dismiss button by default
render Gustwave::Toast.new("Saved.", dismissible: false)  # none
render Gustwave::Toast.new("Saved.") do |toast|
  toast.with_dismiss_button(text: "Close notification")   # customized
end
```

### Icons and other visuals

Visuals are icons, images, SVGs, indicators and custom components. `Gustwave::Visuals` provides three slots for them, and a component declares the ones it places with `renders_visuals`, e.g. `renders_visuals :leading_visuals, :trailing_visuals` (D7):

- **`leading_visuals` and `trailing_visuals`** for visuals inline with text, on either side, as in Buttons, Badge, Tab and Kbd.
- **`visuals`** for visuals the component places itself, such as a toast's or a pagination link's icon.

All three have one shape: a `renders_many_extensible` slot with every type, `icon`, `image`, `svg`, `indicator` and `renderable`. Setters read the same everywhere: `with_visual_icon(:check)`, `with_leading_visual_image(src)`, `with_visual_renderable(MyAvatar.new)`. A slot stays `many` with every type, even where a component normally shows one visual, until a caller needs it narrower. Add a type with `extend_slot`.

- **Sizing is optional.** A component with a `size` variant and an `indicator_size` value sizes its visuals and indicators from them. Without them, its `visual` part sets the visuals' size, and indicators take the Indicator's default size.
- **The `has_visual` toggle**, which makes the root inline-flex, is only for components whose visuals sit inline with text.
- **Icons default to the outline theme.** A component whose Flowbite pattern uses solid icons sets `self.visual_icon_theme = :solid`, so the slot and the `icon:` shorthand agree.
- **Visuals are decorative** and hidden from screen readers. A visual that carries meaning, like an alert's status icon, keeps a slot named after its role that takes a `label:` (D4). So does a visual that isn't one of these types, like Timeline's `marker`.
- **One visual per state** gets a slot per state, named after it. Clipboard shows one icon before copying and another after, and the script swaps between them, so it has `icon` and `copied_icon` rather than `visuals`: one `visuals` slot can't say which state a visual belongs to (D8).

Symbol keywords such as `icon:` and `trailing_icon:` are allowed as **shorthand only**: they must set one of these slots, so the slot can always do anything the keyword can. `Dropdowns::Triggers::Button` is the reference: its `trailing_icon:` calls `with_trailing_visual_icon`. A keyword is never the only way to set an icon, and doesn't come with companions like `icon_theme:` or `icon_options:`. A keyword whose default icon can be turned off, like DismissButton's `icon: :close`, takes `nil` for none.

### HTML attributes

A component's `options` are the HTML attributes of one element, usually its root. A keyword that is one of the component's options always means the option, whatever the value: `size: 5` is an unknown size, not `size="5"`. In strict mode the error says so and names the fix.

**`html:` takes HTML attributes as a hash,** for the same element as `options`. It's the only way to pass an attribute named like an option (D12):

```ruby
render Gustwave::Tabs.new(style: :underline, html: { style: "max-width: 40rem" })
render Gustwave::Form::Input.new(:title, form: f, size: :lg, html: { size: 20 })
```

- **Attributes without a clash stay flat:** `placeholder:`, `class:`, `data:`. Both spellings reach the same element.
- **`html:` wins.** An attribute given flat and in `html:` takes the value in `html:`. That holds for `class`, `data` and `aria` too, which then merge with the component's own as the flat ones do.
- **It works wherever options reach an element,** on components and on slot setters: `timeline.with_item(html: { … })`. A component or slot without an element for its options doesn't take it, like `Form::RichText::Divider` or a `renderable` slot. `Gustwave::Component.new` takes it, so no component declares or handles it, and `attributes_for` and `configure_html_attributes` merge an `html` hash for slots that build markup. A slot or part that renders its attributes without them calls `configure_html_attributes(options)` first.
- **It doesn't reach past a keyword that isn't an option.** `html: { id: … }` is the component's `id:`, as the flat spelling is. Where a slot or a wrapper hands its attributes to another component, a key named like that component's option picks the option.

### Styling a part

Use **`<part>_options:`**: a hash of HTML attributes for a declared `part`, or the options of a component rendered for that element, like ModalHeader's `title_options:` for its `Gustwave::Heading`, merged with `configure_html_attributes`, so caller classes win conflicts. It works at construction, and slot setters forward it, as in `timeline.with_item(marker_options: { class: "..." })`. `class:` on a slot setter styles that slot's root element.

Older components also use `configure_<part>` methods and `<part>_class:` keywords. Both are replaced by `<part>_options:`, after a deprecation (D1).

**Exception: state classes.** Some classes style a state that a script switches, not an element, like the active and inactive classes Flowbite's JavaScript swaps on a tab through `data-tabs-active-classes`. Only classes make sense there, so they're `<state>_class:` keywords that take a string: `Tabs`' `active_class:` and `inactive_class:` (D5).

### Triggers

When the trigger lives elsewhere on the page, the component exposes `trigger_options(...)`, as an instance and a class method, which returns the attributes to spread into any trigger. `Modal`, `Tooltip` and `Popover` do this. When Flowbite renders the trigger next to its target, the trigger is a slot: `Dropdown`, `SpeedDial`.

Flowbite's `data-*-trigger` setting, hover or click, is the keyword **`trigger_event:`** everywhere, because `trigger` is already a slot name.

### Header, body and footer

Overlay and container components expose sections as slots named `header`, `body` and `footer`. Each one is backed by a standalone component, e.g. `ModalHeader`, that takes its parent's ID, so it also works outside the slot, inside a form for example. Add a section when a Flowbite example or a caller needs it, not for symmetry.

### IDs

A component takes `id:` for its own root and generates one with a component-specific prefix when it's blank. A reference to another element is `<target>_id:`: `modal_id:`, `drawer_id:`, `menu_id:`, `toolbar_id:`.

## Wiring and accessibility

- The parent owns wiring. When it builds a slot, it passes IDs, `aria-labelledby` or `aria-describedby`, and Flowbite's `data-*` attributes. Callers never have to repeat them.
- A standalone sub-component takes its wiring as a **required** keyword: `ModalHeader` requires `modal_id:`. It never guesses or silently renders unwired.
- A child that adapts to its parent implements `apply_slot_context` and accepts unknown keywords with `**`, so parents can add context later without breaking it.
- A child that renders only inside its parent says so in its docstring, right after the opening sentence and always in the same words: "Renders only inside a Gustwave::ListGroup; the list sets its position.", naming what the parent sets. Its examples render it through the parent's slot, never on its own.
- Decorative visuals get `aria-hidden`. A visual that carries meaning takes a label keyword.
- Behavior that Flowbite's JavaScript doesn't cover ships as a `gustwave--*` Stimulus controller, which the component wires up itself, e.g. `gustwave--focus-trap` on Modal.

## Forms

Flowbite's form patterns come in three layers, so a form reads like a Rails form and every piece still works on its own (D9). `Form::Input`, `Form::Textarea`, `Form::RichTextarea`, `Form::Select`, `Form::Toggle`, `Form::Checkbox`, `Form::Radio`, `Form::Range`, `Form::InputGroup`, `Form::Field`, `Form::InlineField`, `Form::Fieldset`, `Form::ValidationMessage` and the builder follow it. *Planned:* the other controls.

| Layer | Owns | Example |
|---|---|---|
| A control | One form element: its classes, sizes, validation look and the visuals inside it | `Form::Input`, `Form::Select`, `Form::Toggle`, `Form::Checkbox`, `Form::Radio`, `Form::Range` |
| A field | What surrounds a control: label, helper text and validation message, and the IDs and ARIA attributes that tie them to it | `Form::Field`, `Form::InlineField` |
| `Gustwave::FormBuilder` | No markup. It turns Rails' form helpers into fields | `f.text_field :title` |

```erb
<%= form_with model: @task, builder: Gustwave::FormBuilder do |f| %>
  <%= f.text_field :title, helper_text: "Shown in the task list." %>
<% end %>

<%# The same field without the builder's shorthand, in a form with any builder %>
<%= render Gustwave::Form::Field.new(:title, form: f) do |field| %>
  <% field.with_control_input %>
  <% field.with_helper_text("Shown in the task list.") %>
<% end %>

<%# A control on its own, without a form builder %>
<%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) %>
```

Form components live in `Gustwave::Form`, named after their Flowbite pattern (D11).

### Controls

- **One control per Flowbite pattern, not per Rails helper.** `text_field`, `email_field` and `password_field` all render `Form::Input`, which takes the `type` as an option, because Rails treats the value differently per type. A Flowbite example that only arranges a control with buttons, dropdowns or visuals is `composable`, not a new control, unless they're attached to it with joined corners: that's the input group.
- **The attribute is the positional subject, `form:` is the wiring.** `Form::Input.new(:title, form: f)` binds the control to a form builder, Rails' own or any subclass. An attribute without `form:` raises, as a sub-component without its parent's ID does.
- **Rails renders a bound element.** The control hands its attributes to Rails' helper for that element, so the name, ID, value, type casting, nested attributes and `index` behave as in any Rails form. A control never works them out itself. Without `form:` it renders a plain element, and `name:`, `id:` and `value:` are ordinary HTML attributes.
- **`options` are the form element's attributes:** the `<input>`, `<select>` or `<textarea>`, in every control, also where that element isn't the root. Any other element is a part with `<part>_options:`.
- **Fixed choices are options:** `size`, and `validation` with `:success` and `:error` for Flowbite's validation looks. `disabled`, `readonly` and `required` stay HTML attributes. `size`, `style` and `type` are HTML attributes too, but the keyword is always the option: `size: :lg` is the large input, and `html: { size: 20 }` renders `size="20"`. See [HTML attributes](#html-attributes).
- **Label, helper text and validation messages belong to the field,** not to the control, without exception (D13). A control renders its element and its look, never the label or the arrangement around it. A control rendered on its own gets its accessible name from the caller. `Form::Toggle`'s own `<label>` holds only the input and the track, as the click target, and no text. `Form::Checkbox` is the `<input>` alone.
- **A control may render in a frame.** With a `header` or `footer` slot, `Form::Textarea` renders in Flowbite's frame. The frame's parts take `<part>_options:`; `options` still go to the `<textarea>`. The frame is shared by the controls that have one, in the `Framed` concern. `Form::RichTextarea` always renders in it; its `header` and `footer` are polymorphic, so the toolbar can sit in either.
- **An attached addon makes an input group.** `Form::InputGroup` renders one control with a text, button or dropdown attached beside it, with joined corners, in the field's `control` slot or on its own. It passes the field's context on to its control, and the control joins its own corners (D18). A visual inside the input stays the input's.
- **An action inside the input is a slot.** `Form::Input` renders a button or another element at its end with `with_trailing_action_*`, beside the input in its wrapper, because a visual there would be hidden from screen readers (D20). The input keeps no room for it, so the caller adds the end padding.
- **`Form::Select` departs from Flowbite's classes in two places.** A disabled select has the input's disabled look (gray background, `cursor-not-allowed`), where Flowbite's docs give it the classes of the default select, so every control looks alike when disabled. And the size paddings get `pe-10`: they override the `padding-right: 2.5rem` that `@tailwindcss/forms` reserves for the chevron, so long text ran under it. A list box (`multiple`, or an HTML `size` above 1) has no chevron and keeps the plain padding, and the underline style is left as Flowbite has it.

### Field

A field takes the same `attribute` and `form:` as a control and passes them on, so callers state them once.

- **One field class per label layout (D13).** `Form::Field` stacks the label, the control and the texts. `Form::InlineField` puts the label beside the control, with the helper text under the label, for the toggle, the checkbox and the radio. *Planned:* a field for the floating label. What they share is the `FieldWiring` concern, so the rules below hold for every field. Each field has the control types of its layout.
- **Layout between control and text is the field's.** Flowbite's gap is `ms-3` after a toggle and `ms-2` after a checkbox or a radio, so `Form::InlineField` picks it from the type of its control. A checkbox or a radio also gets Flowbite's `h-5` cell, the height of the label's first line, so it stays beside that line above the helper text (D14, D15). The control carries no layout.
- **The inline field grays the label of a disabled control,** as Flowbite's toggle page does. It asks the control with `disabled?`. With a block as the control, the gray is the label's class.

- **Its parts are slots,** because the field places and wires them: `control`, `label`, `helper_text` and `validation_message`. `control` is polymorphic, with a type per control and a `renderable` type for anything else. An app adds its own controls with `extend_slot`. The other three take text or a block and build markup, not a component. The validation message is rendered by `Form::ValidationMessage`, so its classes live there once and the field has no part for it: the slot's HTML attributes style it.
- **`label:` and `helper_text:` are shorthand** for the slots of the same name, as `icon:` is for a visual. `label: false` renders no label.
- **A bound field has defaults.** Without a `label`, it renders the text Rails' `label` helper finds: a translation, then the humanized attribute. Without a `validation_message`, it renders the attribute's error messages when there are any. A field without `form:` renders only what the caller sets.
- **The field holds the validation state.** Flowbite colors the label and the message along with the control, so `Form::Field` takes `validation:` as well, and one `validation_message` slot shows a success or an error message. While a bound attribute has errors, the state is `:error`. A caller's own `validation:` wins. A bound control on its own defaults to `:error` the same way, without a message (D17).
- **The field wires its control,** through `apply_slot_context`: the validation state, and `aria-describedby` for the helper text and the validation message. The field's state wins over the control's default from the attribute's errors, and the control's own `validation:` wins over both (D17). A control sets `aria-invalid` itself in the error state.
- **Fields of one attribute leave the error to their group (D15).** A control that is one of several for its attribute, like a `multiple` checkbox, answers `shares_attribute?` with true. Its field keeps the validation state but doesn't default to the attribute's error sentence, so the sentence isn't repeated per field. An explicit `validation_message:` is still rendered.
- **IDs come from Rails' `field_id`,** e.g. `field_id(:title, :validation_message)`, so the same attribute in two forms on a page doesn't collide. A field without `form:` generates them.

### Group

A group is what several fields of one attribute share: the radios of a choice and the checkboxes of a `multiple` attribute (D15).

- **`Form::Fieldset` is a `<fieldset>` with a `<legend>`** (its `label` slot), the block, the validation message and a helper text once, below the group, in this order. Its `aria-describedby` names the message and the helper text in that order. The fields inside reference nothing: they need no context from the group, so the block is plain content.
- **`Form::ValidationMessage` is the message on its own,** for a group in the caller's own `<fieldset>`. Bound, it renders the attribute's error sentence under the ID `field_id(attribute, :validation_message)`, which the caller's `aria-describedby` names. The fields use it for their own message, so the message has one set of classes.
- **Flowbite has no fieldset component.** The legend, message and helper text copy the look of `Form::Field`.

### Form builder

`Gustwave::FormBuilder` is a subclass of `ActionView::Helpers::FormBuilder`. A form opts in with `builder: Gustwave::FormBuilder` (D10).

- **It keeps Rails' helper names and signatures.** HTML options still go to the element. One call changes when a form switches to it: a key named like an option of the control is that option, so `size: 20` on `text_field` becomes `html: { size: 20 }`. A helper Gustwave has no control for, like `hidden_field`, renders what Rails renders.
- **A helper renders the field of its control's layout:** `f.toggle`, `f.check_box` and `f.radio_button` render a `Form::InlineField`, the others a `Form::Field`. So `f.check_box` and `f.radio_button` render their label, unlike Rails' (D14, D15).
- **Each helper renders a field with its control,** and also takes the control's options, `html:` and the field's shorthand: `f.text_field :title, size: :lg, helper_text: "…"`.
- **A helper with two option hashes, like `select`, takes Gustwave's options in the first** with Rails' own. The second is the element's HTML attributes, as in Rails, and goes to the control as `html:`, so `f.select :tags, @tags, { size: :lg }, { size: 5 }` is the large select with `size="5"`. The block of `select` stays Rails': it supplies the option tags.
- **A control without a Rails helper gets one named after it:** `f.toggle :publish`.
- **`f.fieldset` and `f.validation_message` have no Rails helper.** They render `Form::Fieldset` and `Form::ValidationMessage` bound to the attribute.
- **The builder holds no markup, classes or behavior.** Whatever it renders can be rendered with `Form::Field` and the controls directly. A new feature goes into a component first, then gets its shorthand.
- **An app extends it with a subclass,** which adds helpers for the app's own controls with `render_field` and `render_inline_field`, and renders the app's own field classes through `field_class` and `inline_field_class`, one per layout, and `fieldset_class` for `fieldset`, as `list_menu_class` does for Dropdown's menu.
- **It follows the [Component lifecycle](#component-lifecycle)** and starts at alpha, with a `@status` tag like a component.

### What stays composition

A group's fields stay plain `Form::InlineField`s in the block of the fieldset, with no slots on the group. No component wraps `form_with` or lays out a form: spacing and grids are Tailwind classes, and a submit button is a `Gustwave::Buttons::*` with `type: :submit`.

## Public API and stability

For an extensible library, extension points are part of the contract:

| Tier | Includes | A change to it |
|---|---|---|
| Public API | Component class names; positional arguments and keywords; option names and values; slot names, types and setters; `<part>_options:`; `html:`; `trigger_options`; the form builder's helper names and signatures; Stimulus controller identifiers | Is breaking. Follows the component's status, see [Component lifecycle](#component-lifecycle). |
| Extension API | Part names; `build_slot_*` builder names and signatures; targets of `extend_slot`, `extend_variant`, `extend_toggle`; `apply_slot_context` keywords; class attributes like `list_menu_class` and the form builder's `field_class` and `inline_field_class`; the form builder's `render_field` and `render_inline_field` | Is breaking. Follows the component's status. |
| Internal | Options marked `internal: true`; private helpers; the class strings themselves, which follow Flowbite | Isn't breaking. |

## Component lifecycle

Every component has a status: alpha, beta or stable. A component on its way out is deprecated. Every new component starts at alpha, and so does every existing component when statuses are introduced (D3).

Every component states its status with a `@status` tag in its class docstring, see [Lifecycle rules](#lifecycle-rules).

### Releases

While Gustwave is at 0.x:

- **Patch releases** only contain fixes. They deprecate nothing and change no API.
- **Minor releases** contain everything else, including breaking changes, each with an upgrade note in the changelog.
- **A deprecation comes one minor release before the removal.** Deprecate in 0.2.0, remove in 0.3.0 (D1).
- **1.0** comes once minor releases no longer break anything: when every component that's meant to ship is stable.

The status says how much of that protection a component gets:

| Status | Meant for | How its public and extension API may change |
|---|---|---|
| Alpha | Early adopters who expect change | In any minor release, with an upgrade note under Breaking Changes. Deprecating first is welcome but not required. |
| Beta | Anyone. The API has settled and is used for real. | Only through a deprecation: deprecated in one minor release, removed in the next. |
| Stable | Anyone, long term | Like beta while Gustwave is at 0.x. From 1.0, removals only in a major release. |
| Deprecated | Nobody new | Logs a warning and is removed in the next minor release. |

After 1.0, alpha and beta components stay exempt from semantic versioning, so new components can still start at alpha.

### From alpha to beta

A component moves to beta when all of these hold:

1. **It follows this document.** No open `gustwave-design` issues for it, and the convention specs pass.
2. **Its Flowbite page is covered.** Every example on the component's Flowbite docs page is `previewed`, `composable`, `tailwind` or `out_of_scope` in `lookbook/flowbite.yml`. Any `partial` or `feature_gap` example names what's missing, and adding it won't change existing keywords or slots.
3. **An application uses it in production.**
4. **It's accessible.** Automated accessibility checks pass on every preview. For interactive components, keyboard and screen reader behavior have been checked by hand.
5. **It's documented.** The class docs have an example for every slot, and there's a preview for every variant.
6. **Its API held still.** Its public and extension API didn't change in the last minor release.

### From beta to stable

A component becomes stable when all of these hold:

1. **Two minor releases without change.** Two consecutive minor releases in beta with no breaking change or deprecation in its public or extension API.
2. **Three or more call sites,** in one or more applications.
3. **Its dependencies are stable.** Every component it exposes through its API (slot types, sub-components, components it renders by default) is stable. `Dropdown` can't be stable before its triggers, menus and menu items are.
4. **No open design questions.** No open issues that would change its API.

### Lifecycle rules

- **Statuses only move forward.** A beta or stable component that needs a breaking change goes through a deprecation; it doesn't go back to alpha.
- **Promotions happen in minor releases** and are listed in the changelog under Changed.
- **The status is a `@status` tag in the class docstring,** next to the YARD tags the gem already uses, as in the example below. It changes nothing at runtime. Every class states its own status, because a docstring isn't inherited: a new theme under a beta `Buttons::Base` still starts at alpha.
- **Lookbook shows the status in its Status panel,** read from the docstring of the component a preview is named after, e.g. `Gustwave::Card` for `Gustwave::CardPreview`. Nothing else repeats it, so the docstring is the only place to change.
- **A deprecated component also warns at runtime.** Its constructor calls `Gustwave.deprecator.warn` with what to use instead. The `@status deprecated` tag alone can't warn.

```ruby
module Gustwave
  # Use Card to group content in a bordered box.
  # ...
  # @status alpha
  class Card < Gustwave::Component
```

## Extension scope

ViewComponent's guide prefers composition over inheritance. Gustwave uses three tools, each for a reason:

- **Composition** (a wrapper component) to name or preset a component in an app. This is the default.
- **A subclass** for a variation that has to coexist with the original, like an extra slot type in one dropdown.
- **`on_load` with `extend_*`** for app-wide changes. It changes the class itself, so it affects every caller and every subclass in the process, tests included. Use it for brand colors, not for one screen.

## Enforcement

Convention specs, like the constructor spec, keep the rules from drifting. Their failure messages name the rule and link to it in this document.

- **Statuses** (`spec/components/component_status_spec.rb`). Every component's class docstring has exactly one `@status` tag with `alpha`, `beta`, `stable` or `deprecated`. A component tagged `deprecated` calls `Gustwave.deprecator.warn`.
- **API snapshot** (`spec/components/api_snapshot_spec.rb`). Each component's status, constructor, options and their values, derived values, parts, slots and their types, public methods and slot builders are recorded in `spec/fixtures/api_snapshots`. Every API change then shows up in review as a fixture diff, and the failure message says what the change needs for the component's status: an upgrade note for alpha, and a deprecation before removing or renaming anything in beta or stable. Run with `UPDATE_API_SNAPSHOTS=1` to record an intended change. Internal options aren't recorded.
- **Conventions** (`spec/components/conventions_spec.rb`), read off each component's declarations and source:
  - A `<name>_options:` keyword names a declared part, or a component the component renders for that element. A `<name>_class:` keyword only names a state class a script swaps, never an element. There are no public `configure_<part>` methods.
  - `icon:` and `trailing_icon:` keywords are shorthand for a slot callers can reach as well.
  - Components that render `DismissButton` expose it as a `dismiss_button` slot. A `dismiss_button:` or `close_button:` keyword comes with the slot of the same name.
  - Flowbite's trigger setting is `trigger_event`, as an option, a keyword and in `trigger_options`.
  - A standalone sub-component requires its parent's ID as `<parent>_id:`.

The conventions spec lists components written before this document as known violations, each with its `gustwave-design` issue. That list only shrinks: once a component is fixed, the spec fails until its entry is removed. Findings that are fine for good, like `Tabs`' state classes (D5), are exceptions with their reason. Add neither for new code; follow the rule instead.

## Decisions

Settled questions, so they aren't reopened without a new reason. A new decision gets the next number.

- **D1. Deprecations come one minor release before the removal.** Never in a patch release. The deprecation goes under Deprecated in the changelog; the removal goes under Breaking Changes with an upgrade note. It applies to beta and stable components. Alpha components change without one, with an upgrade note, as `configure_<part>`, `<part>_class:` for elements, Tooltip's and Popover's `trigger`, SpeedDials::Action's `icon_theme:` and `IconToast` did.
- **D2. No `Component` suffix.** Components are named after their Flowbite pattern: `Gustwave::Card`, `Gustwave::Buttons::Default`. The `Gustwave::` namespace and `app/components` already say what they are. This departs from ViewComponent's recommendation on purpose, as Primer ViewComponents does. Apps choose their own convention for components that wrap Gustwave.
- **D3. Everything starts at alpha.** Every existing component starts at alpha when statuses are introduced, including ones already used in production. Promotions follow [Component lifecycle](#component-lifecycle).
- **D4. Alert keeps a positional `icon` slot.** `Visuals` isn't a fit: it always declares both sides as collections, needs a `size` variant Alert doesn't have, makes the root inline-flex, and hides visuals from screen readers, while Alert's icon carries meaning. Timeline's `marker` is the precedent. See [Icons and other visuals](#icons-and-other-visuals).
- **D5. Tabs keeps `active_class:` and `inactive_class:`, and gets nothing more for now.** Flowbite's own examples need per-instance state classes: the purple active tab, and Card's nav and full-width tabs. `extend_variant :style` alone would need a new style for each. They stay strings, not `active_options:`, because Flowbite swaps them on a state, not an element with attributes. Anything beyond that waits until a caller needs it. See [Styling a part](#styling-a-part).
- **D6. Sub-component slots are reached through the parent slot's block.** A caller customizes a nested part, like a modal header's close button, in the block of the parent's slot setter, which receives the sub-component. ViewComponent already passes it, so parents don't forward their children's slots or options (no `close_button_options:` on `with_header`, no `with_header_close_button`), which would repeat each child's API on every parent. See [Slot or content block](#slot-or-content-block).
- **D7. Visual slots have one shape.** `Visuals` provides `leading_visuals`, `trailing_visuals` and `visuals`, each a `renders_many_extensible` slot with every visual type, and components declare the ones they place. A component's own icon slot, or one that also accepts a component in place of an icon name, would give each component its own way to set a visual and its own subset of types. One shape keeps the setters the same everywhere and lets `extend_slot` add types to all of them. Slots narrow to one visual or fewer types only when a caller asks. `icon:` keywords stay as shorthand for `with_visual_icon`. See [Icons and other visuals](#icons-and-other-visuals).
- **D8. Clipboard keeps an `icon` and a `copied_icon` slot.** Its button shows one icon in the default state and another once the text is copied, and Flowbite's script swaps the two. A single `visuals` slot would need a way to tag each visual with its state, which no other component needs. So each state gets its own `renders_one_extensible` slot that renders a `Gustwave::Icon`, with defaults for an icon-only button (`:clipboard`) and the copied state (`:check`). They become polymorphic, with the visual types of `Visuals`, once a caller needs more than an icon. A component with visuals per state follows this shape. See [Icons and other visuals](#icons-and-other-visuals).
- **D9. Forms are controls, a field and Gustwave's own form builder.** Controls work without a builder, so previews, forms without a model and compositions can use them. `Form::Field` owns the wiring between a control and its label, helper text and errors, which is the part that's easy to get wrong. The builder gives a form Rails' short call sites without holding any markup. Three alternatives were ruled out. Components that only take a builder, as `Form::RichTextarea` did, can't render on their own and repeat `render …new(form, …)` on every line. A builder that holds the class strings has no options, slots, previews or `extend_*`. The `view_component-form` gem slices by Rails helper instead of by Flowbite pattern, constructs every component from a builder, has no field wrapper, and takes its components' parent class from one setting that belongs to the app, so they couldn't use Gustwave's DSL. It would also be a runtime dependency that caps Gustwave's ViewComponent version. See [Forms](#forms).
- **D10. The form builder is opt-in per form.** A form uses it with `builder: Gustwave::FormBuilder`. Gustwave never sets `default_form_builder` or changes Rails' own builder, because that would restyle forms the app didn't write, like Devise's or another engine's, and would force an app to migrate every form at once. An app that wants it everywhere sets `default_form_builder` itself. See [Form builder](#form-builder).
- **D11. Form components live in `Gustwave::Form`; the builder is `Gustwave::FormBuilder`.** Flowbite names its form pages generically: Select, Range, Toggle, Radio. The namespace says they're form controls and keeps them apart from unrelated top-level components. `Form::RichTextarea` already lives there. The builder sits at the top level, named as Rails names builders, since an app writes it on every form. See [Forms](#forms).
- **D12. A keyword named like an option is the option; HTML attributes of that name go in `html:`.** `size`, `style` and `type` are options of many components and HTML attributes as well. So the keyword always means the option, and `html:` takes a hash of HTML attributes for the element `options` go to. Attributes without a clash stay flat, and `html:` wins over a flat attribute of the same name. `Gustwave::Component.new` implements it once for every component, and the error for a rejected value names `html:` when the option is named like an HTML attribute. The form builder sends the second hash of `select` and `collection_select` as `html:`. Telling them apart by the value's type, a Symbol for the option and anything else for the attribute, was ruled out: it makes one keyword mean two things and turns a typo into an attribute. Renaming the options (`control_size`) was ruled out too: it would depart from Flowbite's and the gem's vocabulary across the gem to free a name few callers need as an attribute. See [HTML attributes](#html-attributes).
- **D13. A control is only the control; there is one field class per label layout.** A toggle, a checkbox, a radio button and a floating label need the label somewhere else than above the control. Letting a control render the label itself was ruled out: it breaks D9's split, gives a field two labels, and needs `label: false` on the field. Instead each layout has its field: `Form::Field` stacked, `Form::InlineField` with the label beside the control, and a field for the floating label, which will pass `style` and `size` down to its control as fields pass the validation state. The toggle is a control in the inline field, not a field type. Its own `<label>` wraps only the input and the track, so the switch is clickable, and the field renders the text as a sibling `<label for>`. Accepted costs: Flowbite's single wrapping label becomes two elements, which the preview comparison shows, and the gap between the switch and the text isn't clickable. See [Forms](#forms).
- **D14. The checkbox is the bare input, in one size, and `f.check_box` renders its field.** `Form::Checkbox` renders the `<input type="checkbox">` and nothing else, with `color` as its only look: Flowbite 3.1.2's checkbox page shows seven colors, one size and no validation look, so `validation` only sets `aria-invalid`, as on the toggle. An indeterminate state and sizes wait for a Flowbite example or a caller. Three things follow from D13. `Form::InlineField` gives a checkbox Flowbite's `h-5` cell, picked from the control type like the gap, because the row can't center a box against a label with helper text under it. Examples that restyle the label, like the bordered box and the list group, are composition: classes on the field and its parts, and a `ListGroup` for the list. The checkbox's darker dark mode classes inside a list group or dropdown stay caller classes until a third pattern needs them as an option. And the builder overrides `check_box`, with `checkbox` where Rails has that name, to render the inline field, so it renders a label where Rails' helper renders none; `label: false` leaves it out. `collection_check_boxes` stays Rails'. Flowbite's checkbox dropdown waits for a menu item that holds a checkbox, which belongs to `Dropdown`, not to the checkbox. See [Forms](#forms).
- **D15. A group renders the error once, in a fieldset; the fields of one attribute don't render it.** The radios of a group and the checkboxes of a `multiple` attribute are one `Form::InlineField` each, and each rendered the attribute's error sentence, so it repeated. Now a field whose control answers `shares_attribute?` with true keeps the validation state but doesn't default to the attribute's errors, and the group renders them once: `Form::Fieldset`, with `f.fieldset`, or `Form::ValidationMessage` in the caller's own `<fieldset>`. The message is a component of its own, which the fields render too, so its classes exist once. The rule is the control's: a radio and a `multiple` checkbox opt in with `shares_attribute?`. Three alternatives were ruled out. A `validation_message: false` option on the field is wrong by default: the error repeats until the caller opts out on all but one field. The message would also hang off one field, so only that control would be described by it, and `nil` and `false` would mean different things. Deduplicating through hidden state in the form builder depends on render order, and leaves the message attached to one field. A group component that takes its fields as slots isn't needed: the fields need no context from the group, so a plain block is enough. Accepted costs: a group without `Form::Fieldset` or `Form::ValidationMessage` shows the error state without a message, so `multiple` checkboxes outside a group lose their repeated message, and Flowbite has no fieldset component, so the fieldset's look follows `Form::Field`. See [Forms](#forms).
- **D16. The radio is the bare input, in one size, and the fields of a group stay one per radio.** `Form::Radio` renders the `<input type="radio">` and nothing else, with `color` as its only look, as D14 has it for the checkbox; `validation` only sets `aria-invalid`. It has no checked or unchecked value and no hidden field: its `value` is an HTML attribute, and a bound radio needs one, because Rails derives its ID and its checked state from it. A group is composition, the caller's `Form::Fieldset` (D15) or `<fieldset>` around one `Form::InlineField` per radio, and `collection_radio_buttons` stays Rails'. The radio answers `shares_attribute?` with true, since it is always one of several for its attribute, so its field leaves the attribute's error to the group (D15). Fields that repeat for one attribute needed two more rules in the shared wiring. A field's default label follows the control's `value` when it responds to one that isn't `nil`: the translation Rails' `label(attribute, value:)` finds for that value, otherwise the humanized value, so "Free" and not "Plan" on every radio, also for a form without a model and for a `false` value. And the IDs of the helper text and the validation message follow the control's ID when that extends Rails' ID of the attribute (`task_plan_free_helper_text`), so a group has no duplicate IDs and each `aria-describedby` names its own text; this also fixes `multiple` checkboxes. A fieldset has no control, so its message keeps the attribute's ID. The radio dropdown waits for a menu item that holds a radio, which belongs to `Dropdown`. See [Forms](#forms).
- **D17. A bound control defaults to the error state while its attribute has errors.** `Form::Field` and `Form::ValidationMessage` already defaulted to `:error` for a bound attribute with errors, but a control defaulted to `:none`, so a bound control rendered without a field looked valid and lacked `aria-invalid` while its record had errors. Now every control picks `:error` itself, in `BoundControl`, for an attribute it is bound to directly or through a field's context, with the errors `BoundControl.error_messages` finds, so a `name_id` attribute has those of `name` too. The state is picked late, before the control's own `before_render`, because a field passes its state after the control is built. Precedence, highest first: the control's own `validation:`, the state a parent passes through `apply_slot_context`, so `Form::Field.new(:title, form: f, validation: :none)` still turns it off, the attribute's errors, then `:none`. The effects are the existing ones: the validation look of the controls that have one and `aria-invalid` on all. Accepted cost: a bare bound control shows the error state without a message, since the message belongs to the field (D13); a caller who wants none passes `validation: :none`. See [Forms](#forms).
- **D18. The input group is one control with addons, rendered in the field's `control` slot; each control joins its own corners.** Flowbite's input group attaches an addon beside a control, a text, an icon, a button or a dropdown trigger, with joined corners. `Form::Input` only covers the icon inside the input. The attached look is already built by hand in two Clipboard previews, and several blocked examples share it (a phone country code, a currency, a timepicker with a dropdown, a search with a dropdown), so it's promoted, not predicted. `Form::InputGroup` is a flex row with `leading_addon` and `trailing_addon` slots, one each, with the types `text`, `button`, `dropdown`, `generic` and `renderable`, and one `control` slot (`input`, `select`, `renderable`). `size:` (`:sm`, `:md`, `:lg`, default `:md`) is the group's: it goes to the addons, which have the sizes' padding and text, and to the control unless the control has its own `size:`. There is no `visual` addon type: the text addon takes visuals through `Gustwave::Visuals` and the block (D6), and the `text` addon has one look, Flowbite's gray span, so the clipboard's blue button is a `button` addon with caller classes. The dropdown addon is a `Gustwave::Dropdown` whose trigger is `Form::InputGroups::Button`, registered as the `:input_addon` button theme; its menu is the trigger's sibling in the row. The group is a new control type of `Form::Field`, `field.with_control_input_group`, and also renders on its own. The field passes its context (attribute, form, ID, validation state, `aria-describedby`) to the group through `apply_slot_context`, and the group passes it on to its control, so the label's `for`, `aria-describedby` and `aria-invalid` still point at the one real control. Apart from the new control type, the field doesn't change. The group tells its control which edges are joined, and the control picks its classes from an internal variant `joined:` with `:none`, `:start`, `:end` and `:both`, as `ButtonGroups::Button` picks them from `group_position` and `Form::InlineField` its `gap`. `Form::Input` and `Form::Select` join with the same classes (Flowbite's 2px divider in "Select with dropdown" belongs to the example, and the input has it too), but the control owns the variant: it knows its own markup, an input with an icon has a wrapper that has to fill the row, and its classes sit in its own style snapshot, tested with its sizes and validation states. A renderable control without the variant sits in a group with its rounded corners. *Seam rule:* the addon drops the border of the side facing the control, and the control keeps its whole border, so the validation color stays continuous; Flowbite's examples differ on which of the two drops it. Flowbite's 2px lighter divider and the colored seam of the clipboard are classes on the addon, merged with TailwindMerge, not options. The field's validation state and default message come from the control's one attribute. Flowbite's "Timepicker with select" has a real `<select>` as addon; it stays unbuilt, and if an addon is ever a form element bound to another attribute, the field will ask its control which attributes it covers, as it asks `shares_attribute?` (D15), and the group will answer with its control's attribute and its bound addons'. That's additive. There's only Flowbite's attached look: a control and a button in a row with a gap has no invariant, so it stays composition, and the host app's project select moves its "new initiative" button to the attached look. Seven alternatives were ruled out. The group merging classes into its control's `class:` through the context works with TailwindMerge, but the group would hard-code every control's classes. A `FieldGroup` field with several controls has the stacked layout of `Form::Field`, against D13's one field class per label layout, repeats the wiring, leaves unclear which control the label names, and doesn't join corners. `Form::Field` taking several controls breaks the one-control wiring of every field, treats the addons as controls when they aren't, and would have to restyle them. Addon slots on `Form::Field` make the field restyle its control, would have to be repeated on the floating-label field, and leave a control without a field, like a search in a navbar or a table, without addons. Addon slots on each control, through a concern like `Framed`, put them on every groupable control, give `Form::Input` two different input groups, the icon inside and the addons beside, and put a dropdown in a control's slot. Plain composition copies the joining classes, an invariant, by hand, and a block as the field's control loses the ARIA wiring. A generic group that joins its children with CSS child selectors overrides the controls' classes through specificity instead of class merging, doesn't match Flowbite's markup, and can't tell which element goes on top for the focus ring. Accepted costs: one more nesting level in ERB; each groupable control needs the internal variant; a builder shorthand, like `leading_addon:` on `f.text_field`, waits for a caller; and Flowbite shows no validated input group, so the addon stays gray while the control shows the validation colors. See [Forms](#forms).
- **D19. The range is the bare input in three sizes; its colors are Flowbite's plugin's.** `Form::Range` renders the `<input type="range">` and nothing else. Flowbite 3.1.2's range page shows three sizes, one color and no validation look. Flowbite's plugin styles the thumb in base CSS: its blue, its gray when disabled, its focus ring and the `range-sm` and `range-lg` sizes. So `size` is the only look: the track's height and the plugin's size class. The range has no `color` option, as Flowbite has none, and no `disabled_look`, as the plugin grays the thumb. `validation` only sets `aria-invalid`, as D14 has it for the checkbox. `min`, `max`, `step` and `value` are HTML attributes. Its label goes above it, so it is a control type of `Form::Field`, and the builder overrides `range_field`. Tick labels are composition, spans the caller positions under the track, because Flowbite's one example places them by hand for its values. A color and a live value display wait for a Flowbite example or a caller. Code inside `Gustwave::Form` that means Ruby's range writes `::Range`. See [Forms](#forms).
- **D20. The action inside an input is the `trailing_action` slot, named after its role, not `trailing_visuals`.** A search submit button or a voice search button sits inside the input at its end. `Visuals` is the wrong slot for it: its visuals are decorative and hidden from screen readers (D7), and a button isn't decorative, so `trailing_visuals` would hide the control from assistive technology. So the action gets its own slot, named after what it is, as a visual that carries meaning gets a slot named after its role (D4). Its types are `button`, `generic` and `renderable`, as the addons of `Form::InputGroup` are (D18). It sits in the input's own wrapper, the element that also holds a leading visual, and no content block reaches that position, so the slot is the only way for a caller to place it there. The pattern was already built by hand in the jumbotron and four Clipboard previews, so it's promoted now and not predicted. A `button` takes the size that fits its input: `xs` in an `sm` or `md` input, `sm` in an `lg` input. Measured, the `xs` button left 1px above and below it in an `sm` input, so there it gets `py-1` and keeps the 5px gap it has in an `md` input. The size is the derived value `action_button_size` and the classes are the `action_button` part with its `size` variant classes, as Badge has them for its dismiss button, so a caller's class wins over them. The input reserves no room at its end for the action, so a caller whose text can run under it adds the end padding itself. A `clipboard` type for the Clipboard's copy button is a possible later `extend_slot`, once a caller needs one beyond `button`. See [Forms](#forms).
- **D21. Content above the navbar's items goes in the `menu_header` slot.** Flowbite's "Navbar with search" puts a search field for small screens in the collapsing menu, above the box that holds the links. Every item is a list item inside that box, so a `generic` item draws the field inside the gray box, and no block reaches the menu outside the list: a position the block can't reach (see [Slot or content block](#slot-or-content-block)). The slot renders its block as it is, as `actions` does. The spacing and hiding belong to the example, so the caller wraps the field in `mt-3 md:hidden`, and the slot has no part. The menu and its toggle render with items or a menu header. A footer below the list waits for a Flowbite example or a caller.
