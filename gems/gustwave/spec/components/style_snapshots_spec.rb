# frozen_string_literal: true

require "rails_helper"
require "gustwave/test/style_snapshots"

# Snapshots of the markup each component renders, as a safety net while the
# styling concerns are replaced. Regenerate with UPDATE_STYLE_SNAPSHOTS=1 and
# review the fixture diff.
module Gustwave
  module Specs
    module StyleSnapshots
      # Receives the button's visual context and renders the size as a class, so
      # both the documented html_attributes and size end up in the snapshot.
      class StyleSnapshotVisual < ViewComponent::Base
        def apply_slot_context(size:, html_attributes:, **)
          @size = size
          @html_attributes = html_attributes
        end

        def call
          tag.span(**@html_attributes, class: [ @html_attributes[:class], "context-size-#{@size}" ])
        end
      end

      POSITIONS = %i[none top_left top top_center top_right middle_left center middle middle_center
                     middle_right bottom_left bottom bottom_center bottom_right].freeze
      CUSTOM_CLASS = [ nil, "px-0 bg-black text-white" ].freeze
      BUTTON_SIZES = %i[none xs sm md lg xl].freeze
      BUTTON_THEMES = {
        "Gustwave::Buttons::Default" => %i[none base default alternative dark light green red yellow purple],
        "Gustwave::Buttons::DefaultOutline" => %i[none base default dark green red yellow purple white],
        "Gustwave::Buttons::GradientDuotone" => %i[none base purple_to_blue cyan_to_blue green_to_blue purple_to_pink
                                                   pink_to_orange teal_to_lime red_to_yellow],
        "Gustwave::Buttons::GradientDuotoneOutline" => %i[none base purple_to_blue cyan_to_blue green_to_blue purple_to_pink
                                                          pink_to_orange teal_to_lime red_to_yellow],
        "Gustwave::Buttons::GradientMonochrome" => %i[none base blue green cyan teal lime red pink purple],
        "Gustwave::Buttons::GradientMonochromeColoredShadow" => %i[none base blue green cyan teal lime red pink purple]
      }.freeze
      ALL_VISUALS = ->(button) do
        button.leading_icon :check
        button.leading_image "https://example.com/avatar.png", alt: ""
        button.trailing_svg { "<svg></svg>".html_safe }
        button.trailing_indicator "3"
      end
    end
  end
end

RSpec.describe "Style snapshots", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../fixtures/style_snapshots", __dir__)

  specs = Gustwave::Specs::StyleSnapshots

  it "covers every button theme" do
    expect(Gustwave::Button.themes.values.map(&:name).uniq).to match_array(specs::BUTTON_THEMES.keys)
  end

  { "Gustwave::Buttons::Base" => %i[none base], **specs::BUTTON_THEMES }.each do |name, schemes|
    style_snapshot name do
      button = name.constantize
      group :scheme, content: "Label", scheme: schemes, pill: [ false, true ], tag: %i[button a] do |**args|
        button.new(**args)
      end
      group :size, content: "Label", size: specs::BUTTON_SIZES, class: specs::CUSTOM_CLASS do |**args|
        button.new(**args)
      end
      group :visual_only, slots: ->(b) { b.leading_icon :check }, size: specs::BUTTON_SIZES, scheme: [ schemes[2] || :base, :none ] do |**args|
        button.new(**args)
      end
      group :visuals, content: "Label", slots: specs::ALL_VISUALS, size: specs::BUTTON_SIZES do |**args|
        button.new(**args)
      end
      group :renderable, content: "Label", size: specs::BUTTON_SIZES,
            slots: ->(b) { b.leading_renderable specs::StyleSnapshotVisual.new } do |**args|
        button.new(**args)
      end
    end
  end

  style_snapshot "Gustwave::Button" do
    group :theme, content: "Label", theme: Gustwave::Button.themes.keys.sort, size: %i[sm lg], pill: [ false, true ] do |**args|
      Gustwave::Button.new(**args)
    end
  end

  style_snapshot "Gustwave::Badge" do
    schemes = %i[none base default dark red green yellow indigo purple pink]
    sizes = %i[none xs sm md lg xl 2xl]
    group :scheme, content: "New", scheme: schemes, border: [ false, true ], outline: [ false, true ],
          tag: %i[span a] do |**args|
      Gustwave::Badge.new(**args)
    end
    group :size, content: "New", size: sizes, pill: [ false, true ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Badge.new(**args)
    end
    group :visual_only, slots: ->(b) { b.leading_icon :check }, size: sizes do |**args|
      Gustwave::Badge.new(**args)
    end
    group :visuals, content: "New", slots: ->(b) { b.leading_icon :check }, size: sizes do |**args|
      Gustwave::Badge.new(**args)
    end
    # The dismiss button isn't snapshotted: it requests the unregistered
    # button theme :inline, which raises outside production.
  end

  style_snapshot "Gustwave::Avatar" do
    sizes = %i[none original xs sm md lg xl 2xl 3xl 4xl]
    group :image, src: "https://example.com/avatar.png", scheme: %i[none round square], size: sizes, border: [ false, true ] do |**args|
      Gustwave::Avatar.new(**args)
    end
    group :text, content: "AB", size: %i[md xl], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Avatar.new(**args)
    end
  end

  style_snapshot "Gustwave::AvatarText" do
    group :text, scheme: [ nil, :round, :square ], size: %i[xs sm md lg xl 2xl 3xl 4xl], border: [ nil, true ] do |**args|
      Gustwave::AvatarText.new("AB", **args)
    end
    group :custom, class: specs::CUSTOM_CLASS do |**args|
      Gustwave::AvatarText.new("AB", **args)
    end
  end

  style_snapshot "Gustwave::AvatarPlaceholder" do
    group :placeholder, scheme: [ nil, :square ], size: [ nil, :xl ], border: [ nil, true ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::AvatarPlaceholder.new(**args)
    end
  end

  style_snapshot "Gustwave::AvatarGroup" do
    group :group, class: specs::CUSTOM_CLASS do |**args|
      Gustwave::AvatarGroup.new(**args)
    end
  end

  style_snapshot "Gustwave::Icon" do
    group :look, size: %i[none xs sm md base lg xl 2xl 3xl 4xl 5xl 6xl 7xl 8xl 9xl], scheme: %i[none light dark],
          position: %i[leading trailing inline standalone] do |**args|
      Gustwave::Icon.new(:check, **args)
    end
    group :stroke_width, stroke_width: [ 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4 ], theme: %i[outline solid], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Icon.new(:check, **args)
    end
  end

  style_snapshot "Gustwave::Indicator" do
    group :look, scheme: %i[none gray dark blue green red purple indigo yellow teal white],
          size: %i[none auto xs sm md lg xl], text: [ nil, "3" ] do |text: nil, **args|
      Gustwave::Indicator.new(text, **args)
    end
    group :position, position: specs::POSITIONS, pulse: [ false, true ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Indicator.new(**args)
    end
  end

  style_snapshot "Gustwave::Spinner" do
    group :look, scheme: %i[none base blue dark green red yellow pink purple], size: %i[xs md xl] do |**args|
      Gustwave::Spinner.new(**args)
    end
    group :layout, align: %i[none left center right], position: specs::POSITIONS, class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Spinner.new(**args)
    end
  end

  style_snapshot "Gustwave::Toast" do
    group :toast, content: "Saved", position: %i[none top_left top_center top_right bottom_left bottom_center bottom_right],
          dismissible: [ true, false ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Toast.new(**args)
    end
  end

  style_snapshot "Gustwave::IconToast" do
    group :toast, scheme: %i[none info notice success error failure warning alert], dismissible: [ true, false ] do |**args|
      Gustwave::IconToast.new("Saved", **args)
    end
    group :layout, position: %i[none top_left bottom_right], icon: [ nil, :check ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::IconToast.new("Saved", **args)
    end
  end

  style_snapshot "Gustwave::HorizontalLine" do
    group :plain, scheme: %i[none default trimmed squared], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::HorizontalLine.new(**args)
    end
    group :content, content: "or", scheme: %i[none default trimmed squared] do |**args|
      Gustwave::HorizontalLine.new(**args)
    end
    group :block_content, content: "<b>or</b>".html_safe, scheme: %i[default] do |**args|
      Gustwave::HorizontalLine.new(**args)
    end
    group :visual_text, slots: ->(line) { line.text "or", class: "px-0" }, scheme: %i[none default] do |**args|
      Gustwave::HorizontalLine.new(**args)
    end
    group :visual_svg, slots: ->(line) { line.svg { "<svg></svg>".html_safe } }, scheme: %i[none default] do |**args|
      Gustwave::HorizontalLine.new(**args)
    end
  end

  style_snapshot "Gustwave::Heading" do
    group :heading, content: "Title", tag: %i[h1 h3 h6], scheme: [ nil, :none, :level1, :level2, :level3, :level4, :level5, :level6 ],
          responsive: [ false, true ] do |scheme: nil, **args|
      Gustwave::Heading.new(**args, **{ scheme: }.compact)
    end
    group :custom, content: "Title", tag: :h2, class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Heading.new(**args)
    end
  end

  style_snapshot "Gustwave::DismissButton" do
    group :size, size: %i[xs sm md lg xl], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::DismissButton.new("#toast", **args)
    end
  end

  style_snapshot "Gustwave::Popover" do
    group :popover, content: "Tip", id: "popover", arrow: [ true, false ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Popover.new(**args)
    end
  end

  style_snapshot "Gustwave::RichText" do
    group :rich_text, class: specs::CUSTOM_CLASS do |**args|
      Gustwave::RichText.new("<p>Text</p>".html_safe, **args)
    end
  end

  style_snapshot "Gustwave::Containers::ResponsiveHorizontalScroll" do
    group :scroll, content: "Items", breakpoint: %i[sm md lg xl 2xl], snap: %i[none start center end] do |**args|
      Gustwave::Containers::ResponsiveHorizontalScroll.new(**args)
    end
    group :custom, content: "Items", class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Containers::ResponsiveHorizontalScroll.new(**args)
    end
  end

  style_snapshot "Gustwave::Table" do
    table = lambda do |t|
      t.with_caption_slot { "Caption" }
      t.with_head_slot { |head| head.with_column("Name") }
      t.with_body_slot { "<tr><td>Ada</td></tr>".html_safe }
    end
    group :table, slots: table, scheme: %i[none standard], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Table.new(**args)
    end
  end

  {
    "Gustwave::TableCaption" => ->(**args) { Gustwave::TableCaption.new(**args) },
    "Gustwave::TableHead" => ->(**args) { Gustwave::TableHead.new(**args) },
    "Gustwave::TableRow" => ->(**args) { Gustwave::TableRow.new(**args) }
  }.each do |name, build|
    style_snapshot name do
      group :scheme, content: "Cell", scheme: %i[none standard], class: specs::CUSTOM_CLASS do |**args|
        build.call(**args)
      end
    end
  end

  style_snapshot "Gustwave::TableCell" do
    group :cell, tag: %i[td th], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::TableCell.new("Ada", **args)
    end
  end

  style_snapshot "Gustwave::Dropdown" do
    menu = lambda do |dropdown|
      dropdown.menu do |list|
        list.header "Header"
        list.item "Edit", href: "/edit", icon: :check, trailing_icon: :check
        list.divider
        list.dropdown "More"
        list.generic_item { "Generic" }
        list.footer "Footer"
      end
    end
    group :button_trigger, slots: menu, icon: [ nil, :check ], inline: [ false, true ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Dropdown.new("Menu", menu_id: "menu", **args)
    end
  end

  style_snapshot "Gustwave::Dropdowns::Triggers" do
    group :generic, content: "Open", tag: %i[div span], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Dropdowns::Triggers::Generic.new(menu_id: "menu", **args)
    end
    group :inline_button, content: "Open", class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Dropdowns::Triggers::InlineButton.new(menu_id: "menu", **args)
    end
    group :button, content: "Open", icon: [ nil, :check ], trailing_icon: [ nil, :check ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Dropdowns::Triggers::Button.new(menu_id: "menu", **args)
    end
  end

  style_snapshot "Gustwave::Dropdowns::Menus" do
    group :generic, content: "Body", class: specs::CUSTOM_CLASS,
          slots: ->(menu) { menu.header("Header") && menu.footer("Footer") } do |**args|
      Gustwave::Dropdowns::Menus::Generic.new(id: "menu", **args)
    end
    group :list, class: specs::CUSTOM_CLASS, slots: ->(menu) { menu.item("Edit") && menu.divider } do |**args|
      Gustwave::Dropdowns::Menus::List.new(id: "menu", **args)
    end
  end

  style_snapshot "Gustwave::Dropdowns::MenuItems" do
    group :link_button, icon: [ nil, :check ], trailing_icon: [ nil, :check ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Dropdowns::MenuItems::LinkButton.new("Edit", **args)
    end
    group :divider, tag: %i[div li], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Dropdowns::MenuItems::Divider.new(**args)
    end
  end

  style_snapshot "Gustwave::Form::RichTextArea" do
    editor = ->(area) { area.editor { "<textarea></textarea>".html_safe } }
    group :area, slots: editor, sticky_toolbar: [ true, false ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Form::RichTextArea.new(toolbar_id: "toolbar", **args)
    end
  end

  style_snapshot "Gustwave::Form::RichText::Lexxy" do
    group :toolbar, hidden: [ [], [ :bold ] ], disabled: [ [], [ :italic ] ], class: specs::CUSTOM_CLASS do |**args|
      Gustwave::Form::RichText::Lexxy::Toolbar.new(id: "toolbar", **args)
    end
    group :button, attribute: %i[bold heading2 quote], disabled: [ false, true ], class: specs::CUSTOM_CLASS do |attribute:, **args|
      Gustwave::Form::RichText::Lexxy::Button.new(attribute, **args)
    end
  end
end
