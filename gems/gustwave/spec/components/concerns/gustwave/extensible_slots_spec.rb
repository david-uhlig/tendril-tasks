require "rails_helper"

RSpec.describe Gustwave::ExtensibleSlots, type: :component do
  let(:item_component) do
    stub_const("ExtensibleSlotsItem", Class.new(Gustwave::Component) {
      def initialize(label = nil, **options)
        @label = label
        @options = options
      end

      def call
        tag.em(@label || content, **@options)
      end
    })
  end

  let(:list_component) do
    item = item_component
    stub_const("ExtensibleSlotsList", Class.new(Gustwave::Component) {
      renders_many_extensible :entries, types: {
        text: ->(text, **options) { tag.span(text, **options) },
        component: item,
        named: { renders: ->(text) { tag.b(text) }, as: :bold_entry }
      }

      renders_one_extensible :title_slot, types: {
        text: ->(text) { tag.h1(text) },
        block: ->(&block) { tag.h2(capture(&block)) }
      }

      def call
        tag.div { safe_join([ title_slot, *entries ]) }
      end
    })
  end

  context "when declaring a slot" do
    it "renders lambda types through the generated setters" do
      render_inline(list_component.new) do |list|
        list.with_title_slot_block_content("content")
        list.with_entry_text("lambda", class: "x")
      end

      expect(rendered_content).to have_selector("h2", text: "content")
      expect(rendered_content).to have_selector("span.x", text: "lambda")
    end

    it "sets any type by name through the singular setter" do
      render_inline(list_component.new) { |list| list.with_entry(:text, "by name") }

      expect(rendered_content).to have_selector("span", text: "by name")
    end

    it "instantiates component classes with the arguments" do
      render_inline(list_component.new) { |list| list.with_entry_component("label", class: "y") }

      expect(rendered_content).to have_selector("em.y", text: "label")
    end

    it "passes the block to component classes as content" do
      render_inline(list_component.new) do |list|
        list.with_entry_component { "block content" }
      end

      expect(rendered_content).to have_selector("em", text: "block content")
    end

    it "names the setter after +as:+" do
      render_inline(list_component.new) { |list| list.with_bold_entry("bold") }

      expect(rendered_content).to have_selector("b", text: "bold")
    end

    it "passes blocks to lambda types" do
      render_inline(list_component.new) do |list|
        list.with_title_slot_block { "captured" }
      end

      expect(rendered_content).to have_selector("h2", text: "captured")
    end

    it "keeps the builders private" do
      expect(list_component.private_method_defined?(:build_entry_text)).to be(true)
      expect(list_component.private_method_defined?(:build_title_slot_text)).to be(true)
    end

    it "registers the slots and their types" do
      expect(list_component.extensible_slots).to eq(
        entries: { collection: true, types: %i[text component named] },
        title_slot: { collection: false, types: %i[text block] }
      )
    end

    # Specs prepend Gustwave::Test::SingleSetSlots, which raises before the
    # slot's own guard runs, so the guard is exercised directly.
    it "raises like ViewComponent when a renders_one slot is set twice" do
      component = list_component.new
      component.send(:__gustwave_guard_single_set, :title_slot)

      expect {
        component.send(:__gustwave_guard_single_set, :title_slot)
      }.to raise_error(ViewComponent::ContentAlreadySetForPolymorphicSlotError)
    end

    it "allows setting renders_many slots repeatedly" do
      component = list_component.new

      expect {
        2.times { component.send(:__gustwave_guard_single_set, :entries) }
      }.not_to raise_error
    end

    it "is caught by the single-set spec helper" do
      expect {
        render_inline(list_component.new) do |list|
          list.with_title_slot_text("one")
          list.with_title_slot_text("two")
        end
      }.to raise_error(Gustwave::Test::SingleSetSlots::SlotAlreadySetError)
    end

    it "raises on unknown types" do
      expect {
        render_inline(list_component.new) { |list| list.with_entry(:missing) }
      }.to raise_error(Gustwave::ExtensibleSlots::UnknownSlotTypeError, /no type :missing \(known: :text, :component, :named\)/)
    end

    it "rejects types that are not lambdas, classes or class names" do
      expect {
        Class.new(Gustwave::Component) { renders_many_extensible :things, types: { bad: 42 } }
      }.to raise_error(ArgumentError, /must be a lambda, class or class name/)
    end
  end

  context "when extending a slot in a subclass" do
    let(:extended_component) do
      stub_const("ExtensibleSlotsExtendedList", Class.new(list_component) {
        extend_slot :entries, types: {
          badge: ->(text) { tag.mark(text) },
          text: ->(text, **) { tag.strong(text) }
        }
      })
    end

    it "adds a type with a generated setter" do
      render_inline(extended_component.new) do |list|
        list.with_entry_badge("new")
        list.with_entry_component("inherited")
      end

      expect(rendered_content).to have_selector("mark", text: "new")
      expect(rendered_content).to have_selector("em", text: "inherited")
    end

    it "replaces an existing type" do
      render_inline(extended_component.new) { |list| list.with_entry_text("replaced") }

      expect(rendered_content).to have_selector("strong", text: "replaced")
      expect(rendered_content).not_to have_selector("span")
    end

    it "leaves the parent untouched" do
      extended_component

      expect(list_component.method_defined?(:with_entry_badge)).to be(false)
      expect(list_component.extensible_slots[:entries][:types]).to eq(%i[text component named])
      expect(extended_component.extensible_slots[:entries][:types]).to eq(%i[text component named badge])
    end

    it "accepts builder methods defined directly" do
      subclass = stub_const("ExtensibleSlotsDefList", Class.new(list_component) {
        private def build_entry_avatar(src) = tag.img(src:)
      })

      render_inline(subclass.new) { |list| list.with_entry(:avatar, "me.png") }

      expect(rendered_content).to have_selector("img[src='me.png']")
    end

    it "raises for slots not declared as extensible" do
      expect {
        Class.new(list_component) { extend_slot :unknown, types: { x: ->() { } } }
      }.to raise_error(Gustwave::ExtensibleSlots::NotExtensibleSlotError)
    end
  end

  context "when accepting any renderable" do
    let(:aware_component) do
      stub_const("ExtensibleSlotsAware", Class.new(Gustwave::Component) {
        attr_reader :context

        def initialize(label = nil) = @label = label
        def apply_slot_context(**context) = @context = context
        def call = tag.i(@label || content, data: { tone: context&.dig(:tone), slot: context&.dig(:slot) })
      })
    end

    let(:host_component) do
      stub_const("ExtensibleSlotsHost", Class.new(Gustwave::Component) {
        renders_many_extensible :entries, types: {
          text: ->(text) { tag.span(text) }
        }, renderable: :entry_context

        renders_one_extensible :footer_slot, types: {}, renderable: true

        def call = tag.div { safe_join([ *entries, footer_slot ]) }

        private def entry_context = { tone: :loud }
      })
    end

    it "registers a renderable type next to the declared ones" do
      expect(host_component.extensible_slots[:entries][:types]).to eq(%i[text renderable])
    end

    it "passes the slot context to components implementing the protocol" do
      render_inline(host_component.new) do |host|
        host.with_entry_renderable(aware_component.new("aware"))
      end

      expect(rendered_content).to have_selector("i[data-tone='loud'][data-slot='entries']", text: "aware")
    end

    it "renders components without the protocol unchanged" do
      render_inline(host_component.new) do |host|
        host.with_entry_renderable(item_component.new("plain"))
        host.with_entry_text("text")
      end

      expect(rendered_content).to have_selector("em", text: "plain")
      expect(rendered_content).to have_selector("span", text: "text")
    end

    it "passes the slot's block to the component as content" do
      render_inline(host_component.new) do |host|
        host.with_entry_renderable(aware_component.new) { "from block" }
      end

      expect(rendered_content).to have_selector("i", text: "from block")
    end

    it "passes only the slot name when no context method is given" do
      component = aware_component.new
      render_inline(host_component.new) { |host| host.with_footer_slot_renderable(component) }

      expect(component.context).to eq(slot: :footer_slot)
    end

    it "rejects objects that cannot be rendered" do
      expect {
        render_inline(host_component.new) { |host| host.with_entry_renderable("a string") }
      }.to raise_error(ArgumentError, /slot :entries expects a renderable/)
    end
  end
end
