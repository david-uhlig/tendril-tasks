require "rails_helper"

RSpec.describe Gustwave::Styling do
  def component(parent = Gustwave::Component, &block)
    Class.new(parent, &block)
  end

  let(:button) do
    component do
      base "inline-flex", unless: { scheme: :none }
      part :icon, "h-4"
      variant :scheme, default: :blue, values: { blue: "bg-blue-500", red: "bg-red-500" }
      variant :size, default: :md, values: {
        sm: { root: "text-sm px-2", icon: "h-3" },
        md: "text-base px-4"
      }
      toggle :pill, "rounded-full"
    end
  end

  describe "#classes" do
    it "applies the base and every variant's default" do
      expect(button.new.classes).to eq "inline-flex bg-blue-500 text-base px-4"
    end

    it "applies the selected values" do
      expect(button.new.style_with(scheme: :red, size: :sm, pill: true).classes)
        .to eq "inline-flex bg-red-500 text-sm px-2 rounded-full"
    end

    it "returns a part's classes" do
      instance = button.new.style_with(size: :sm)

      expect(instance.classes(:icon)).to eq "h-3"
      expect(button.new.classes(:icon)).to eq "h-4"
    end

    it "lets call-time options override the selection" do
      instance = button.new.style_with(scheme: :red)

      expect(instance.classes(scheme: :blue)).to eq "inline-flex bg-blue-500 text-base px-4"
      expect(instance.classes).to eq "inline-flex bg-red-500 text-base px-4"
    end

    it "adds class: last, so it wins conflicts, and accepts arrays" do
      expect(button.new.classes(class: [ "bg-black", [ "px-0" ] ])).to eq "inline-flex text-base bg-black px-0"
    end

    it "returns nil without classes" do
      expect(component.new.classes).to be_nil
    end

    it "emits classes in declaration order, regardless of the selection's order" do
      ordered = component do
        variant :a, default: :x, values: { x: "p-1" }
        variant :b, default: :x, values: { x: "p-2" }
      end

      expect(ordered.new.style_with(b: :x, a: :x).classes).to eq "p-2"
    end
  end

  describe "variants" do
    it "adds a :none value that renders nothing unless one is declared" do
      instance = button.new.style_with(scheme: :none)

      expect(button.variant_values(:scheme)).to eq %i[blue red none]
      expect(instance.classes).to eq "text-base px-4"
    end

    it "keeps a declared :none value" do
      bordered = component { variant :border, default: :none, values: { none: "border-0", md: "border-2" } }

      expect(bordered.new.classes).to eq "border-0"
    end

    it "converts strings and numbers to symbols" do
      stroked = component { variant :stroke, default: 1.5, values: { "1.5": "stroke-[1.5]", "2": "stroke-2" } }

      expect(stroked.variant_default(:stroke)).to eq :"1.5"
      expect(stroked.new.style_with(stroke: 2).classes).to eq "stroke-2"
      expect(stroked.new.style_with(stroke: "2").style_value(:stroke)).to eq :"2"
    end

    it "targets a part with part:" do
      sized = component do
        part :icon
        variant :size, part: :icon, default: :md, values: { md: "h-5" }
      end

      expect(sized.new.classes).to be_nil
      expect(sized.new.classes(:icon)).to eq "h-5"
    end
  end

  describe "toggles" do
    it "is off by default" do
      expect(button.new.style_value(:pill)).to be false
    end

    it "casts values to booleans" do
      expect(button.new.style_with(pill: "true").style_value(:pill)).to be true
      expect(button.new.style_with(pill: "false").style_value(:pill)).to be false
    end

    it "styles both states with on: and off:" do
      visible = component { toggle :visible, on: "opacity-100", off: "opacity-0" }

      expect(visible.new.classes).to eq "opacity-0"
      expect(visible.new.style_with(visible: true).classes).to eq "opacity-100"
    end

    it "depends on a variant with per:" do
      bordered = component do
        variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
        toggle :border, per: :size, values: { sm: "ring-1", md: "ring-2" }
      end

      expect(bordered.new.style_with(border: true, size: :sm).classes).to eq "text-sm ring-1"
      expect(bordered.new.style_with(border: true, size: :none).classes).to be_nil
    end

    it "targets a part with part:" do
      sticky = component do
        part :toolbar, "flex"
        toggle :sticky, "sticky top-0", part: :toolbar
      end

      expect(sticky.new.style_with(sticky: true).classes(:toolbar)).to eq "flex sticky top-0"
    end
  end

  describe "unless:" do
    let(:guarded) do
      component do
        base "font-medium", unless: { size: [ :xs, :sm ] }
        part :icon, "h-4", unless: { icon: false }
        variant :size, default: :md, values: { xs: "text-xs", sm: "text-sm", md: "text-base" }
        variant :scheme, default: :blue, values: { blue: "text-blue-500" }, unless: { size: :xs }
        toggle :icon
        toggle :pill, "rounded-full", unless: { size: :xs }
      end
    end

    it "skips a declaration for the listed values" do
      expect(guarded.new.classes).to eq "font-medium text-base text-blue-500"
      expect(guarded.new.style_with(size: :sm).classes).to eq "text-sm text-blue-500"
      expect(guarded.new.style_with(size: :xs, pill: true).classes).to eq "text-xs"
    end

    it "works on parts and with toggles" do
      expect(guarded.new.classes(:icon)).to be_nil
      expect(guarded.new.style_with(icon: true).classes(:icon)).to eq "h-4"
    end
  end

  describe "#style_with" do
    it "merges repeated calls" do
      instance = button.new.style_with(scheme: :red).style_with(size: :sm)

      expect(instance.style_value(:scheme)).to eq :red
      expect(instance.style_value(:size)).to eq :sm
    end

    it "treats nil and DEFAULT as the default" do
      expect(button.new.style_with(scheme: nil, size: Gustwave::Styling::DEFAULT).classes)
        .to eq "inline-flex bg-blue-500 text-base px-4"
    end

    it "raises for unknown options and values, with suggestions" do
      expect { button.new.style_with(colour: :red) }
        .to raise_error(Gustwave::Styling::UnknownOptionError, /no style option :colour/)
      expect { button.new.style_with(size: :smm) }
        .to raise_error(Gustwave::Styling::UnknownValueError, /Did you mean :sm\?.*falls back to :md/m)
    end

    context "in production" do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it "ignores unknown options and falls back to the default for unknown values" do
        instance = button.new.style_with(colour: :red, size: :small)

        expect(instance.classes).to eq "inline-flex bg-blue-500 text-base px-4"
      end

      it "returns only class: for an unknown part" do
        expect(button.new.classes(:label, class: "ms-1")).to eq "ms-1"
      end
    end
  end

  describe "lookups" do
    let(:sized) do
      component do
        variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
        lookup :icon_size, per: :size, values: { sm: :xs, md: :sm }
      end
    end

    it "returns the value for the variant's value in effect" do
      expect(sized.new.style_lookup(:icon_size)).to eq :sm
      expect(sized.new.style_with(size: :sm).style_lookup("icon_size")).to eq :xs
    end

    it "takes overrides for one call" do
      expect(sized.new.style_lookup(:icon_size, size: :sm)).to eq :xs
    end

    it "returns nil for an implicit :none it doesn't cover" do
      expect(sized.new.style_with(size: :none).style_lookup(:icon_size)).to be_nil
    end

    it "adds no classes" do
      expect(sized.new.classes).to eq "text-base"
    end

    it "raises for unknown lookups, also in production" do
      allow(Rails.env).to receive(:production?).and_return(true)

      expect { sized.new.style_lookup(:icon_sise) }
        .to raise_error(Gustwave::Styling::UnknownLookupError, /no lookup :icon_sise. Did you mean :icon_size\?/)
    end

    it "is extended and removed in subclasses without changing the parent" do
      child = component(sized) do
        extend_variant :size, values: { lg: "text-lg" }
        extend_lookup :icon_size, values: { lg: :md }
      end
      removed = component(sized) { remove_lookup :icon_size }

      expect(child.new.style_with(size: :lg).style_lookup(:icon_size)).to eq :md
      expect { removed.new.style_lookup(:icon_size) }.to raise_error(Gustwave::Styling::UnknownLookupError)
      expect(sized.style_definition.lookups[:icon_size].values.keys).to eq %i[sm md]
    end
  end

  describe "#style_value" do
    it "returns the value in effect" do
      expect(button.new.style_value(:size)).to eq :md
      expect(button.new.style_with(size: :sm).style_value("size")).to eq :sm
    end

    it "raises for unknown options" do
      expect { button.new.style_value(:colour) }.to raise_error(Gustwave::Styling::UnknownOptionError)
    end
  end

  describe "#attributes_for" do
    it "adds the root classes merged with the caller's class" do
      instance = button.new

      expect(instance.attributes_for({ "id" => "go", class: "px-0" }))
        .to eq(id: "go", class: "inline-flex bg-blue-500 text-base px-0")
    end

    it "keeps the classes when the caller passes class: nil" do
      expect(button.new.attributes_for({ class: nil })).to eq(class: "inline-flex bg-blue-500 text-base px-4")
    end

    it "styles a part and takes overrides" do
      expect(button.new.attributes_for(:icon, { aria: { hidden: true } }, size: :sm))
        .to eq(aria: { hidden: true }, class: "h-3")
    end

    it "leaves out class when there are no classes" do
      expect(component.new.attributes_for({ class: "" })).to eq({})
    end

    it "raises for unknown parts" do
      expect { button.new.attributes_for(:label, {}) }.to raise_error(Gustwave::Styling::UnknownPartError, /no part :label/)
    end
  end

  describe "#merge_classes" do
    it "merges with TailwindMerge" do
      expect(button.new.merge_classes("px-2 py-1", [ "px-4" ], nil)).to eq "py-1 px-4"
    end

    it "uses an inheritable class_merger" do
      merger = TailwindMerge::Merger.new(config: { prefix: "tw-" })
      parent = component { class_merger merger }

      expect(component(parent).class_merger).to be merger
      expect(component.class_merger).to be Gustwave::TailwindHelper::MERGER
    end
  end

  describe "inheritance" do
    it "inherits declarations" do
      expect(component(button).new.classes).to eq "inline-flex bg-blue-500 text-base px-4"
    end

    it "replaces a redeclared name in place" do
      child = component(button) do
        base "flex"
        variant :scheme, default: :green, values: { green: "bg-green-500" }
      end

      expect(child.new.classes).to eq "flex bg-green-500 text-base px-4"
      expect(child.variant_values(:scheme)).to eq %i[green none]
    end

    it "merges with extend_variant, per value and part, and can change the default" do
      child = component(button) do
        extend_variant :size, default: :lg, values: { sm: "text-xs", lg: { root: "text-lg", icon: "h-6" } }
      end
      instance = child.new

      expect(instance.style_with(size: :sm).classes(:icon)).to eq "h-3"
      expect(instance.style_with(size: :sm).classes).to eq "inline-flex bg-blue-500 text-xs"
      expect(child.new.classes).to eq "inline-flex bg-blue-500 text-lg"
      expect(child.new.classes(:icon)).to eq "h-6"
    end

    it "merges with extend_toggle, extend_base and extend_part" do
      child = component(button) do
        extend_base({ icon: "shrink-0" }, unless: {})
        extend_part :icon, "h-5"
        extend_toggle :pill, off: "rounded-sm"
      end

      expect(child.new.style_with(scheme: :none).classes).to eq "inline-flex text-base px-4 rounded-sm"
      expect(child.new.classes(:icon)).to eq "shrink-0 h-5"
    end

    it "deletes with remove_*" do
      child = component(button) do
        remove_toggle :pill
        remove_variant :size
        remove_part :icon
      end

      expect(child.new.classes).to eq "inline-flex bg-blue-500"
      expect(child.style_definition.parts).to eq [ :root ]
    end

    it "doesn't change the parent" do
      component(button) { extend_variant :scheme, values: { green: "bg-green-500" } }

      expect(button.variant_values(:scheme)).to eq %i[blue red none]
    end

    it "reaches loaded subclasses when the parent is extended later" do
      extending = component(button)
      redefining = component(button) { variant :scheme, default: :gray, values: { gray: "bg-gray-500" } }
      expect(extending.new.classes).to eq "inline-flex bg-blue-500 text-base px-4"

      button.extend_variant :scheme, values: { brand: "bg-brand" }

      expect(extending.new.style_with(scheme: :brand).classes).to eq "inline-flex bg-brand text-base px-4"
      expect(redefining.variant_values(:scheme)).to eq %i[gray none]
    end

    it "works when included directly into a ViewComponent" do
      plain = Class.new(ViewComponent::Base) do
        include Gustwave::Styling

        base "flex"
      end

      expect(plain.new.classes).to eq "flex"
    end
  end

  describe "definition errors" do
    def resolve(&block)
      component(&block).style_definition
    end

    it "is raised when the definition is resolved, also in production" do
      allow(Rails.env).to receive(:production?).and_return(true)

      expect { resolve { variant :size, default: :xl, values: { md: "" } } }
        .to raise_error(Gustwave::Styling::DefinitionError, /default :xl of variant :size/)
    end

    it "is raised for per: toggles that don't cover the variant" do
      expect do
        resolve do
          variant :size, default: :md, values: { sm: "", md: "" }
          toggle :border, per: :size, values: { md: "ring-2", xl: "ring-4" }
        end
      end.to raise_error(Gustwave::Styling::DefinitionError, /no classes for :size \[:sm\].*unknown :size \[:xl\]/m)
    end

    it "is raised for per: on something that isn't a variant" do
      expect { resolve { toggle :border, per: :size, values: {} } }
        .to raise_error(Gustwave::Styling::DefinitionError, /per :size, which isn't a variant/)
    end

    it "is raised for lookups that don't cover the variant" do
      expect do
        resolve do
          variant :size, default: :md, values: { sm: "", md: "" }
          lookup :icon_size, per: :size, values: { md: :sm, xl: :lg }
        end
      end.to raise_error(Gustwave::Styling::DefinitionError, /lookup :icon_size has no values for :size \[:sm\].*unknown :size \[:xl\]/m)
    end

    it "is raised for lookups per something that isn't a variant" do
      expect { resolve { toggle :pill; lookup :radius, per: :pill, values: {} } }
        .to raise_error(Gustwave::Styling::DefinitionError, /lookup :radius is per :pill, which isn't a variant/)
    end

    it "is raised when an extension of the variant isn't covered by its lookups" do
      parent = component do
        variant :size, default: :md, values: { md: "" }
        lookup :icon_size, per: :size, values: { md: :sm }
      end
      child = component(parent)
      parent.style_definition
      child.style_definition

      parent.extend_variant :size, values: { xl: "" }

      expect { child.style_definition }
        .to raise_error(Gustwave::Styling::DefinitionError, /lookup :icon_size has no values for :size \[:xl\]/)
    end

    it "is raised for unknown unless: options and values" do
      expect { resolve { base "flex", unless: { scheme: :none } } }
        .to raise_error(Gustwave::Styling::DefinitionError, /unless: :scheme/)
      expect do
        resolve do
          variant :size, default: :md, values: { md: "" }
          base "flex", unless: { size: :xl }
        end
      end.to raise_error(Gustwave::Styling::DefinitionError, /unknown values \[:xl\]/)
    end

    it "is raised for unknown parts" do
      expect { resolve { base icon: "h-4" } }
        .to raise_error(Gustwave::Styling::DefinitionError, /unknown parts \[:icon\]/)
    end

    it "is raised for extending or removing something undefined" do
      expect { resolve { extend_variant :size, values: {} } }
        .to raise_error(Gustwave::Styling::DefinitionError, /variant :size isn't defined/)
      expect { resolve { toggle(:size); remove_variant :size } }
        .to raise_error(Gustwave::Styling::DefinitionError, /variant :size isn't defined \(it's a toggle\)/)
    end

    it "lets an extension finish before checking" do
      extended = component do
        variant :size, default: :md, values: { md: "" }
        toggle :border, per: :size, values: { md: "ring-2" }
      end
      extended.extend_variant :size, values: { xl: "" }
      extended.extend_toggle :border, values: { xl: "ring-4" }

      expect(extended.new.style_with(size: :xl, border: true).classes).to eq "ring-4"
    end
  end

  describe "readers" do
    it "describes the definition" do
      expect(button.variant_default(:size)).to eq :md
      expect(button.new.variant_default(:scheme)).to eq :blue
      expect(button.style_definition.to_h).to eq(
        parts: %i[root icon],
        variants: { scheme: { default: :blue, values: %i[blue red none] }, size: { default: :md, values: %i[sm md none] } },
        toggles: [ :pill ],
        lookups: {}
      )
      expect(component(button) { lookup :icon_size, per: :size, values: { sm: :xs, md: :sm } }.style_definition.to_h[:lookups])
        .to eq(icon_size: { per: :size, values: %i[sm md] })
    end

    it "raises for unknown variants" do
      expect { button.variant_values(:pill) }.to raise_error(Gustwave::Styling::UnknownOptionError)
    end
  end

  describe "DEFAULT" do
    it "is a named sentinel" do
      expect(Gustwave::Styling::DEFAULT.inspect).to eq "DEFAULT"
      expect(Gustwave::Styling::DEFAULT).to be_frozen
    end

    it "resolves to the default of the instance's class" do
      parent = component do
        variant :scheme, default: :blue, values: { blue: "bg-blue-500" }

        # A block's constants resolve lexically, so a class built with
        # Class.new names DEFAULT in full. A class body finds it unqualified.
        def initialize(scheme: Gustwave::Styling::DEFAULT)
          style_with(scheme:)
        end
      end
      child = component(parent) { extend_variant :scheme, default: :red, values: { red: "bg-red-500" } }

      expect(parent.new.classes).to eq "bg-blue-500"
      expect(child.new.classes).to eq "bg-red-500"
    end
  end
end
