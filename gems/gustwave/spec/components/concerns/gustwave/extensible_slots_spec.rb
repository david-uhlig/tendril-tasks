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

      renders_one_extensible :title, types: {
        text: ->(text) { tag.h1(text) },
        block: ->(&block) { tag.h2(capture(&block)) }
      }

      def call
        tag.div { safe_join([ title, *entries ]) }
      end
    })
  end

  context "when declaring a slot" do
    it "renders lambda types through the generated setters" do
      render_inline(list_component.new) do |list|
        list.with_title_block_content("content")
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

    it "rejects an +as:+ name that is the slot's own setter" do
      expect {
        Class.new(Gustwave::Component) {
          renders_one_extensible :trigger, types: {
            generic: { renders: ->(text) { text }, as: :trigger }
          }
        }
      }.to raise_error(ArgumentError, /slot :trigger type :generic can't use as: :trigger, which is the slot's own setter/)
    end

    it "passes blocks to lambda types" do
      render_inline(list_component.new) do |list|
        list.with_title_block { "captured" }
      end

      expect(rendered_content).to have_selector("h2", text: "captured")
    end

    it "keeps the builders private" do
      expect(list_component.private_method_defined?(:build_slot_entry_text)).to be(true)
      expect(list_component.private_method_defined?(:build_slot_title_text)).to be(true)
    end

    it "registers the slots and their types" do
      expect(list_component.extensible_slots).to eq(
        entries: { collection: true, types: %i[text component named] },
        title: { collection: false, types: %i[text block] }
      )
    end

    # Specs prepend Gustwave::Test::SingleSetSlots, which raises before the
    # slot's own guard runs, so the dispatcher is exercised directly with the
    # builder stubbed.
    it "raises like ViewComponent when a renders_one slot is set twice" do
      component = list_component.new
      allow(component).to receive(:build_slot_title_text).and_return("built")
      component.send(:__gustwave_build_slot, :title, :text, "one")

      expect {
        component.send(:__gustwave_build_slot, :title, :text, "two")
      }.to raise_error(ViewComponent::ContentAlreadySetForPolymorphicSlotError)
    end

    it "does not count a renders_one slot as set when its builder raises" do
      component = list_component.new
      allow(component).to receive(:build_slot_title_text).and_raise(ArgumentError, "bad text")

      expect {
        component.send(:__gustwave_build_slot, :title, :text, "one")
      }.to raise_error(ArgumentError, "bad text")

      allow(component).to receive(:build_slot_title_text).and_return("built")
      expect(component.send(:__gustwave_build_slot, :title, :text, "retry")).to eq("built")
    end

    it "does not count a renders_one slot as set for unknown types" do
      component = list_component.new
      allow(component).to receive(:build_slot_title_text).and_return("built")

      expect {
        component.send(:__gustwave_build_slot, :title, :missing)
      }.to raise_error(Gustwave::ExtensibleSlots::UnknownSlotTypeError)
      expect(component.send(:__gustwave_build_slot, :title, :text, "retry")).to eq("built")
    end

    it "allows setting renders_many slots repeatedly" do
      component = list_component.new
      allow(component).to receive(:build_slot_entry_text).and_return("built")

      expect {
        2.times { component.send(:__gustwave_build_slot, :entries, :text, "entry") }
      }.not_to raise_error
    end

    # The set-slot flag is never reset, which relies on ViewComponent refusing
    # to render an instance twice.
    it "relies on ViewComponent refusing to render an instance twice" do
      component = list_component.new
      render_inline(component) { |list| list.with_title_text("one") }

      expect {
        render_inline(component) { |list| list.with_title_text("one") }
      }.to raise_error(ViewComponent::ReusedInstanceError)
    end

    it "is caught by the single-set spec helper" do
      expect {
        render_inline(list_component.new) do |list|
          list.with_title_text("one")
          list.with_title_text("two")
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
        private def build_slot_entry_avatar(src) = tag.img(src:)
      })

      render_inline(subclass.new) { |list| list.with_entry(:avatar, "me.png") }

      expect(rendered_content).to have_selector("img[src='me.png']")
    end

    it "rejects an +as:+ name that is the slot's own setter" do
      expect {
        Class.new(list_component) {
          extend_slot :entries, types: {
            generic: { renders: ->(text) { text }, as: :entry }
          }
        }
      }.to raise_error(ArgumentError, /slot :entries type :generic can't use as: :entry, which is the slot's own setter/)
    end

    it "raises for slots not declared as extensible" do
      expect {
        Class.new(list_component) { extend_slot :unknown, types: { x: ->() { } } }
      }.to raise_error(Gustwave::ExtensibleSlots::NotExtensibleSlotError)
    end
  end

  context "when declaring a single-type slot" do
    let(:card_component) do
      item = item_component
      stub_const("ExtensibleSlotsCard", Class.new(Gustwave::Component) {
        renders_one_extensible :heading, ->(text = nil, **options, &block) {
          tag.h1(text || block&.call, **options)
        }
        renders_many_extensible :tags, ->(text) { tag.mark(text) }
        renders_one_extensible :footer, item
        renders_many_extensible :notes, "ExtensibleSlotsItem"

        def call = tag.div { safe_join([ heading, *tags, footer, *notes ]) }
      })
    end

    it "renders lambda slots through ViewComponent's setters" do
      render_inline(card_component.new) do |card|
        card.with_heading("Title", class: "x")
        card.with_tag("one")
        card.with_tag("two")
      end

      expect(rendered_content).to have_selector("h1.x", text: "Title")
      expect(rendered_content).to have_selector("mark", count: 2)
    end

    it "passes blocks to lambda slots" do
      render_inline(card_component.new) { |card| card.with_heading { "captured" } }

      expect(rendered_content).to have_selector("h1", text: "captured")
    end

    it "keeps ViewComponent's content setter" do
      render_inline(card_component.new) { |card| card.with_heading_content("content") }

      expect(rendered_content).to have_selector("h1", text: "content")
    end

    it "sets renders_many slots from a collection" do
      render_inline(card_component.new) { |card| card.with_tags(%w[a b c]) }

      expect(rendered_content).to have_selector("mark", count: 3)
    end

    it "instantiates component classes and class names with the arguments" do
      render_inline(card_component.new) do |card|
        card.with_footer("footer", class: "y")
        card.with_note("note")
      end

      expect(rendered_content).to have_selector("em.y", text: "footer")
      expect(rendered_content).to have_selector("em", text: "note")
    end

    it "passes the block to component classes as content" do
      render_inline(card_component.new) { |card| card.with_footer { "block content" } }

      expect(rendered_content).to have_selector("em", text: "block content")
    end

    it "names the private builders after the singular slot name" do
      expect(card_component.private_method_defined?(:build_slot_heading)).to be(true)
      expect(card_component.private_method_defined?(:build_slot_tag)).to be(true)
      expect(card_component.private_method_defined?(:build_slot_note)).to be(true)
    end

    it "registers the slots without types" do
      expect(card_component.extensible_slots).to eq(
        heading: { collection: false },
        tags: { collection: true },
        footer: { collection: false },
        notes: { collection: true }
      )
    end

    it "is caught by the single-set spec helper" do
      expect {
        render_inline(card_component.new) do |card|
          card.with_heading("one")
          card.with_heading("two")
        end
      }.to raise_error(Gustwave::Test::SingleSetSlots::SlotAlreadySetError)
    end

    it "applies builder overrides in subclasses" do
      subclass = stub_const("ExtensibleSlotsBoldCard", Class.new(card_component) {
        private

        def build_slot_heading(text = nil, **options, &block)
          super(text&.upcase, class: "bold", **options, &block)
        end
      })

      render_inline(subclass.new) { |card| card.with_heading("title") }

      expect(rendered_content).to have_selector("h1.bold", text: "TITLE")
    end

    it "keeps builders apart from helpers named after the slot" do
      subclass = stub_const("ExtensibleSlotsHelperCard", Class.new(card_component) {
        private

        def build_tag(*) = raise("helper called instead of the slot builder")
      })

      render_inline(subclass.new) { |card| card.with_tag("tagged") }

      expect(rendered_content).to have_selector("mark", text: "tagged")
    end

    it "replaces the builder with extend_slot" do
      subclass = stub_const("ExtensibleSlotsStrongCard", Class.new(card_component) {
        extend_slot :tags, ->(text) { tag.strong(text) }
      })

      render_inline(subclass.new) { |card| card.with_tag("replaced") }

      expect(rendered_content).to have_selector("strong", text: "replaced")
      expect(rendered_content).not_to have_selector("mark")

      render_inline(card_component.new) { |card| card.with_tag("parent") }

      expect(rendered_content).to have_selector("mark", text: "parent")
    end

    it "rejects types: when extending a single-type slot" do
      expect {
        Class.new(card_component) { extend_slot :tags, types: { x: ->() { } } }
      }.to raise_error(ArgumentError, /slot :tags has a single type/)
    end

    it "rejects a callable when extending a polymorphic slot" do
      expect {
        Class.new(list_component) { extend_slot :entries, ->() { } }
      }.to raise_error(ArgumentError, /slot :entries is polymorphic/)
    end

    it "requires either a callable or types:" do
      expect {
        Class.new(Gustwave::Component) { renders_one_extensible :thing }
      }.to raise_error(ArgumentError, /needs either a callable or types:/)

      expect {
        Class.new(Gustwave::Component) { renders_one_extensible :thing, ->() { }, types: {} }
      }.to raise_error(ArgumentError, /needs either a callable or types:/)
    end

    it "rejects renderable: without types:" do
      expect {
        Class.new(Gustwave::Component) { renders_many_extensible :things, ->() { }, renderable: true }
      }.to raise_error(ArgumentError, /renderable: needs types:/)
    end

    it "rejects callables that are not lambdas, classes or class names" do
      expect {
        Class.new(Gustwave::Component) { renders_one_extensible :thing, 42 }
      }.to raise_error(ArgumentError, /must be a lambda, class or class name/)
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

        renders_one_extensible :footer, types: {}, renderable: true

        def call = tag.div { safe_join([ *entries, footer ]) }

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
      render_inline(host_component.new) { |host| host.with_footer_renderable(component) }

      expect(component.context).to eq(slot: :footer)
    end

    it "rejects objects that cannot be rendered" do
      expect {
        render_inline(host_component.new) { |host| host.with_entry_renderable("a string") }
      }.to raise_error(ArgumentError, /slot :entries expects a renderable/)
    end
  end

  describe "errors" do
    it "inherit from their own base error, not Gustwave::Error" do
      [ Gustwave::ExtensibleSlots::UnknownSlotTypeError, Gustwave::ExtensibleSlots::NotExtensibleSlotError ].each do |error|
        expect(error).to be < Gustwave::ExtensibleSlots::Error
        expect(error).not_to be < Gustwave::Error
      end
    end
  end
end
