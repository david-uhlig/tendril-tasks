# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::InputGroup, type: :component do
  def classes_of(node) = class_set(node[:class])

  def children_of(node) = node.all(:xpath, "./*")

  def root = page.find("div.flex", match: :first)

  def render_group(**options, &block)
    block ||= ->(group) { group.with_control_input(name: "q", aria: { label: "Search" }) }
    render_inline(described_class.new(**options)) { |group| block.call(group) }
  end

  def render_field(*args, group_options: {}, **kwargs, &block)
    block ||= ->(group) { group.with_control_input }
    render_inline(Gustwave::Form::Field.new(*args, **kwargs)) do |field|
      field.with_control_input_group(**group_options) { |group| block.call(group) }
    end
  end

  describe "on its own" do
    it "renders a flex row with the control and the addons in order" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_input(name: "username", aria: { label: "Username" })
        group.with_trailing_addon_text(".com")
      end

      expect(classes_of(root)).to eq(class_set("flex"))
      expect(children_of(root).map(&:tag_name)).to eq(%w[span input span])
      expect(page.find("input")[:id]).to be_nil
      expect(page.find("input")[:name]).to eq("username")
    end

    it "takes the caller's HTML attributes" do
      render_group(class: "w-96", data: { x: 1 })

      expect(classes_of(root)).to include("flex", "w-96")
      expect(root["data-x"]).to eq("1")
    end

    it "renders a select as the control" do
      render_group do |group|
        group.with_control_select(name: "zone", choices: %w[UTC CET])
        group.with_trailing_addon_text("zone")
      end

      expect(page).to have_css("select[name=zone] option", count: 2)
    end

    it "renders a renderable control as it is" do
      render_group { |group| group.with_control_renderable(Gustwave::Form::Textarea.new(name: "t")) }

      expect(page).to have_css("textarea[name=t]")
    end
  end

  describe "the addons" do
    it "styles a text addon per side" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_input
        group.with_trailing_addon_text(".com")
      end

      leading, trailing = page.all("span")
      expect(classes_of(leading)).to include("rounded-s-md", "border-e-0", "bg-gray-200", "px-3", "py-2.5", "text-sm")
      expect(classes_of(leading)).not_to include("rounded-e-md", "border-s-0")
      expect(classes_of(trailing)).to include("rounded-e-md", "border-s-0")
      expect(leading.text).to eq("@")
    end

    it "gives the addons the group's size" do
      render_group(size: :sm) do |group|
        group.with_leading_addon_text("@")
        group.with_trailing_addon_button("Go")
      end
      expect(classes_of(page.find("span"))).to include("px-3", "py-2", "text-xs")
      expect(classes_of(page.find("button"))).to include("px-3", "py-2", "text-xs")

      render_group(size: :lg) do |group|
        group.with_leading_addon_text("@")
        group.with_trailing_addon_button("Go")
      end
      expect(classes_of(page.find("span"))).to include("px-4", "py-3", "text-base")
      expect(classes_of(page.find("button"))).to include("px-5", "py-3", "text-base")
    end

    it "takes visuals in the text addon" do
      render_group do |group|
        group.with_leading_addon_text { |addon| addon.with_leading_visual_icon(:user_circle) }
        group.with_control_input
      end

      expect(page).to have_css("span svg[aria-hidden=true]")
    end

    it "renders a default button addon joined to the control, per side" do
      render_group do |group|
        group.with_leading_addon_button("Go")
        group.with_control_input
        group.with_trailing_addon_button("Copy")
      end

      leading, trailing = page.all("button")
      expect(trailing[:type]).to eq("button")
      expect(trailing.text).to eq("Copy")
      expect(classes_of(leading)).to include("bg-blue-700", "text-white", "rounded-s-lg", "border-e-0", "rounded-none", "shrink-0")
      expect(classes_of(leading)).not_to include("rounded-e-lg", "rounded-lg", "bg-gray-100")
      expect(classes_of(trailing)).to include("bg-blue-700", "rounded-e-lg", "border-s-0", "shrink-0")
      expect(classes_of(trailing)).not_to include("rounded-s-lg", "rounded-lg", "bg-gray-100")
    end

    it "renders a button addon in another theme with its options" do
      render_group do |group|
        group.with_control_input
        group.with_trailing_addon_button("New", theme: :outline, color: :green)
      end

      button = page.find("button")
      expect(classes_of(button)).to include("rounded-e-lg", "border-s-0", "text-green-700", "border-green-700")
      expect(classes_of(button)).not_to include("bg-blue-700", "rounded-lg")
    end

    it "renders the grey addon look with theme: :input_addon" do
      render_group do |group|
        group.with_control_input
        group.with_trailing_addon_button("Copy", theme: :input_addon, class: "bg-blue-700")
      end

      button = page.find("button")
      expect(classes_of(button)).to include("rounded-e-lg", "border", "border-s-0", "bg-blue-700", "shrink-0")
      expect(classes_of(button)).not_to include("bg-gray-100", "rounded-s-lg")
    end

    it "keeps the caller's classes on a button addon" do
      render_group do |group|
        group.with_control_input
        group.with_trailing_addon_button("Go", class: "bg-red-700 px-8")
      end

      expect(classes_of(page.find("button"))).to include("bg-red-700", "px-8", "rounded-e-lg")
    end

    it "maps the group's size to the button's size" do
      render_group(size: :sm) { |group| group.with_trailing_addon_button("Go") }
      expect(classes_of(page.find("button"))).to include("px-3", "py-2", "text-xs")

      render_group(size: :sm) { |group| group.with_trailing_addon_button("Go", size: :lg) }
      expect(classes_of(page.find("button"))).to include("px-5", "py-3", "text-base")
    end

    it "keeps the group's size on a button addon given an HTML size attribute in html:" do
      render_group(size: :sm) { |group| group.with_trailing_addon_button("Go", html: { size: 5 }) }

      expect(page.find("button")[:size]).to eq("5")
      expect(classes_of(page.find("button"))).to include("px-3", "py-2", "text-xs")
    end

    it "renders a dropdown addon with the menu as the trigger's sibling" do
      render_group do |group|
        group.with_leading_addon_dropdown("All categories", menu_id: "cats") do |dropdown|
          dropdown.with_menu_list { |menu| menu.with_item_link("Mockups") }
        end
        group.with_control_input
      end

      expect(children_of(root).map(&:tag_name)).to eq(%w[button div input])
      trigger = page.find("button")
      expect(trigger["data-dropdown-toggle"]).to eq("cats")
      expect(classes_of(trigger)).to include("rounded-s-lg", "border-e-0", "bg-gray-100", "px-4")
      expect(root.find(:xpath, "./div")[:id]).to eq("cats")
    end

    it "renders the menu items of a dropdown addon as buttons" do
      render_group do |group|
        group.with_trailing_addon_dropdown("AM") do |dropdown|
          dropdown.with_menu_list { |menu| menu.with_item_link("PM", tag: :button, href: nil) }
        end
        group.with_control_input
      end

      item = page.find("ul button")
      expect(item.text).to eq("PM")
      expect(item[:href]).to be_nil
    end

    it "renders a generic addon as it is" do
      render_group do |group|
        group.with_leading_addon_generic { "<b>x</b>".html_safe }
        group.with_control_input
      end

      expect(children_of(root).map(&:tag_name)).to eq(%w[b input])
    end

    it "gives a renderable addon its side and size" do
      addon = Class.new(Gustwave::Component) do
        def self.name = "TestAddon"

        def apply_slot_context(**context) = @context = context

        def call = tag.i(@context.slice(:side, :size).to_json)
      end

      render_group(size: :lg) do |group|
        group.with_leading_addon_renderable(addon.new)
        group.with_control_input
      end

      expect(page.find("i").text).to eq({ side: :leading, size: :lg }.to_json)
    end
  end

  describe "joining the control" do
    def control_classes = classes_of(page.find("input"))

    it "joins the start edge with a leading addon" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_input
      end

      expect(control_classes).to include("rounded-none", "rounded-e-lg", "flex-1", "min-w-0", "border")
      expect(control_classes).not_to include("rounded-lg", "rounded-s-lg", "border-s-0")
    end

    it "joins the end edge with a trailing addon" do
      render_group do |group|
        group.with_control_input
        group.with_trailing_addon_text(".com")
      end

      expect(control_classes).to include("rounded-none", "rounded-s-lg", "flex-1")
      expect(control_classes).not_to include("rounded-e-lg")
    end

    it "joins both edges with two addons" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_input
        group.with_trailing_addon_text(".com")
      end

      expect(control_classes).to include("rounded-none", "flex-1")
      expect(control_classes).not_to include("rounded-s-lg", "rounded-e-lg", "rounded-lg")
    end

    it "keeps the corners of a renderable control without the variant" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_renderable(Gustwave::Form::Textarea.new(name: "t"))
      end

      expect(classes_of(page.find("textarea"))).to include("rounded-lg")
    end

    it "makes an input with an icon fill the row" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_input(icon: :envelope)
      end

      wrapper = root.find(:xpath, "./div")
      expect(classes_of(wrapper)).to include("relative", "flex-1", "min-w-0")
    end

    it "joins a select" do
      render_group do |group|
        group.with_leading_addon_text("@")
        group.with_control_select(choices: %w[a])
      end

      expect(classes_of(page.find("select"))).to include("rounded-none", "rounded-e-lg", "flex-1")
    end
  end

  describe "the size" do
    it "gives the control the group's size" do
      render_group(size: :lg) { |group| group.with_control_input }
      expect(classes_of(page.find("input"))).to include("p-4", "text-base")

      render_group(size: :sm) { |group| group.with_control_select(choices: %w[a]) }
      expect(classes_of(page.find("select"))).to include("p-2", "text-sm")
    end

    it "keeps the control's own size" do
      render_group(size: :lg) { |group| group.with_control_input(size: :sm) }

      expect(classes_of(page.find("input"))).to include("p-2", "text-xs")
      expect(classes_of(page.find("input"))).not_to include("p-4")
    end

    it "defaults to md" do
      render_group { |group| group.with_control_input }

      expect(classes_of(page.find("input"))).to include("p-2.5", "text-sm")
    end
  end

  describe "in a Field" do
    it "ties the label, ID and description to the control" do
      render_field(:title, form: form_builder, helper_text: "Help") do |group|
        group.with_leading_addon_text("@")
        group.with_control_input
      end

      input = page.find("input")
      expect(page.find("label")[:for]).to eq("task_title")
      expect(input[:id]).to eq("task_title")
      expect(input[:name]).to eq("task[title]")
      expect(input[:"aria-describedby"]).to eq("task_title_helper_text")
      expect(page.all("[id]").map { |node| node[:id] }.count("task_title")).to eq(1)
      expect(page).to have_css("div > div.flex")
      expect(root[:"aria-describedby"]).to be_nil
      expect(page).to have_no_css("span[aria-describedby]")
    end

    it "marks only the control invalid, with the validation border whole" do
      render_field(:title, form: form_builder(invalid_task)) do |group|
        group.with_leading_addon_text("@")
        group.with_control_input
      end

      input = page.find("input")
      expect(input[:"aria-invalid"]).to eq("true")
      expect(input[:"aria-describedby"]).to eq("task_title_validation_message")
      expect(classes_of(input)).to include("border-red-500", "border", "rounded-e-lg")
      expect(classes_of(input)).not_to include("border-s-0")
      expect(page.all("[aria-invalid]").size).to eq(1)
      expect(page.find("p#task_title_validation_message").text).to eq("Can't be blank")
    end

    it "takes the field's validation state" do
      render_field(:title, form: form_builder, validation: :success) { |group| group.with_control_input }

      expect(classes_of(page.find("input"))).to include("border-green-500")
    end

    it "labels the control by the ID the caller gave it" do
      render_field(label: "Name") { |group| group.with_control_input(id: "own-id", name: "name") }

      expect(page.find("input")[:id]).to eq("own-id")
      expect(page.find("label")[:for]).to eq("own-id")
      expect(children_of(page.find("div", match: :first)).map(&:tag_name).first(2)).to eq(%w[label div])
    end

    it "gives a control without a form the field's generated ID" do
      render_field(label: "Name") { |group| group.with_control_input(name: "name") }

      expect(page.find("label")[:for]).to eq(page.find("input")[:id])
      expect(page.find("input")[:id]).to start_with("field")
    end

    it "wires a select as the control" do
      render_field(:country, form: form_builder) do |group|
        group.with_leading_addon_text("Country")
        group.with_control_select(choices: %w[CA FR])
      end

      expect(page.find("label")[:for]).to eq("task_country")
      expect(page.find("select")[:id]).to eq("task_country")
    end

    it "passes the group's size to the control" do
      render_field(:title, form: form_builder, group_options: { size: :lg }) { |group| group.with_control_input }

      expect(classes_of(page.find("input"))).to include("p-4")
    end
  end
end
