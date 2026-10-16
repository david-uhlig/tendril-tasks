require "rails_helper"

RSpec.describe Gustwave::Styling do
  def component(parent = Gustwave::Component, &block)
    Class.new(parent, &block)
  end

  let(:button) do
    component do
      base "inline-flex"
      unstyled scheme: :none
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
      expect(button.new.select_options(scheme: :red, size: :sm, pill: true).classes)
        .to eq "inline-flex bg-red-500 text-sm px-2 rounded-full"
    end

    it "returns a part's classes" do
      instance = button.new.select_options(size: :sm)

      expect(instance.classes(:icon)).to eq "h-3"
      expect(button.new.classes(:icon)).to eq "h-4"
    end

    it "lets call-time options override the selection" do
      instance = button.new.select_options(scheme: :red)

      expect(instance.classes(scheme: :blue)).to eq "inline-flex bg-blue-500 text-base px-4"
      expect(instance.classes).to eq "inline-flex bg-red-500 text-base px-4"
    end

    it "adds class: last, so it wins conflicts, and accepts arrays" do
      expect(button.new.classes(class: [ "bg-black", [ "px-0" ] ])).to eq "inline-flex text-base bg-black px-0"
    end

    it "returns nil without classes" do
      expect(component.new.classes).to be_nil
    end

    it "returns only class: for an unknown part when Gustwave isn't strict" do
      Gustwave.strict = false

      expect(button.new.classes(:label, class: "ms-1")).to eq "ms-1"
    end

    it "emits classes in declaration order, regardless of the selection's order" do
      ordered = component do
        variant :a, default: :x, values: { x: "p-1" }
        variant :b, default: :x, values: { x: "p-2" }
      end

      expect(ordered.new.select_options(b: :x, a: :x).classes).to eq "p-2"
    end
  end

  describe "variants" do
    it "adds a :none value that renders nothing unless one is declared" do
      instance = button.new.select_options(scheme: :none)

      expect(button.option_values(:scheme)).to eq %i[blue red none]
      expect(instance.classes).to eq "text-base px-4"
    end

    it "keeps a declared :none value" do
      bordered = component { variant :border, default: :none, values: { none: "border-0", md: "border-2" } }

      expect(bordered.new.classes).to eq "border-0"
    end

    it "converts strings and numbers to symbols" do
      stroked = component { variant :stroke, default: 1.5, values: { "1.5": "stroke-[1.5]", "2": "stroke-2" } }

      expect(stroked.option_default(:stroke)).to eq :"1.5"
      expect(stroked.new.select_options(stroke: 2).classes).to eq "stroke-2"
      expect(stroked.new.select_options(stroke: "2").option_value(:stroke)).to eq :"2"
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

  describe "internal variants" do
    it "marks a variant the component selects itself with internal: true" do
      statused = component { variant :status, default: :open, internal: true, values: { open: "bg-green-100", closed: "bg-gray-100" } }

      expect(statused.option_definition.option(:status)).to be_internal
      expect(button.option_definition.option(:size)).not_to be_internal
      expect(statused.new.select_options(status: :closed).classes).to eq "bg-gray-100"
    end
  end

  describe "toggles" do
    it "is off by default" do
      expect(button.new.option_value(:pill)).to be false
    end

    it "is on by default with default: true" do
      sticky = component { toggle :sticky, default: true, on: "sticky", off: "static" }

      expect(sticky.new.option_value(:sticky)).to be true
      expect(sticky.new.classes).to eq "sticky"
      expect(sticky.new.select_options(sticky: false).classes).to eq "static"
    end

    it "marks a toggle the component selects itself with internal: true" do
      squared = component { toggle :visual_only, "p-2", internal: true }

      expect(squared.option_definition.option(:visual_only)).to be_internal
      expect(button.option_definition.option(:pill)).not_to be_internal
      expect(squared.new.select_options(visual_only: true).classes).to eq "p-2"
    end

    it "casts values to booleans" do
      expect(button.new.select_options(pill: "true").option_value(:pill)).to be true
      expect(button.new.select_options(pill: "false").option_value(:pill)).to be false
    end

    it "styles both states with on: and off:" do
      visible = component { toggle :visible, on: "opacity-100", off: "opacity-0" }

      expect(visible.new.classes).to eq "opacity-0"
      expect(visible.new.select_options(visible: true).classes).to eq "opacity-100"
    end

    it "depends on a variant with per:" do
      bordered = component do
        variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
        toggle :border, per: :size, values: { sm: "ring-1", md: "ring-2" }
      end

      expect(bordered.new.select_options(border: true, size: :sm).classes).to eq "text-sm ring-1"
      expect(bordered.new.select_options(border: true, size: :none).classes).to be_nil
    end

    it "depends on a plain option with per:, covering each of its values" do
      hovered = component do
        option :tag, default: :span, values: %i[span a]
        toggle :hover, per: :tag, values: { span: "", a: "hover:underline" }
      end

      expect(hovered.new.select_options(tag: :a, hover: true).classes).to eq "hover:underline"
      expect { component { option(:tag, default: :a, values: %i[a span]); toggle :hover, per: :tag, values: { a: "" } }.style_definition }
        .to raise_error(Gustwave::DefinitionError, /toggle :hover has no classes for :tag \[:span\]/)
    end

    it "targets a part with part:" do
      sticky = component do
        part :toolbar, "flex"
        toggle :sticky, "sticky top-0", part: :toolbar
      end

      expect(sticky.new.select_options(sticky: true).classes(:toolbar)).to eq "flex sticky top-0"
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
      expect(guarded.new.select_options(size: :sm).classes).to eq "text-sm text-blue-500"
      expect(guarded.new.select_options(size: :xs, pill: true).classes).to eq "text-xs"
    end

    it "works on parts and with toggles" do
      expect(guarded.new.classes(:icon)).to be_nil
      expect(guarded.new.select_options(icon: true).classes(:icon)).to eq "h-4"
    end
  end

  describe "unstyled" do
    it "skips the base styles for the given values, and only them" do
      expect(button.new.select_options(scheme: :none).classes).to eq "text-base px-4"
      expect(button.new.select_options(scheme: :none, size: :sm).classes(:icon)).to eq "h-3"
      expect(button.new.select_options(scheme: :red).classes).to eq "inline-flex bg-red-500 text-base px-4"
    end

    it "skips the base styles of parts" do
      spinner = component do
        base root: "flex", icon: "animate-spin"
        unstyled scheme: :none
        part :icon, "h-4"
        variant :scheme, default: :blue, values: { blue: "fill-blue-600" }
      end

      expect(spinner.new.classes(:icon)).to eq "animate-spin h-4"
      expect(spinner.new.select_options(scheme: :none).classes(:icon)).to eq "h-4"
    end

    it "takes several options and values" do
      several = component(button) { unstyled scheme: :none, size: %i[sm] }

      expect(several.new.select_options(size: :sm).classes).to eq "bg-blue-500 text-sm px-2"
      expect(several.new.select_options(scheme: :none).classes).to eq "text-base px-4"
    end

    it "is inherited, reaches a redeclared base, and can be replaced" do
      redeclared = component(button) { base "flex" }
      replaced = component(button) { unstyled scheme: :red }

      expect(redeclared.new.select_options(scheme: :none).classes).to eq "text-base px-4"
      expect(replaced.new.select_options(scheme: :none).classes).to eq "inline-flex text-base px-4"
      expect(replaced.new.select_options(scheme: :red).classes).to eq "bg-red-500 text-base px-4"
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
      expect(child.option_values(:scheme)).to eq %i[green none]
    end

    it "merges with extend_variant, per value and part, and can change the default" do
      child = component(button) do
        extend_variant :size, default: :lg, values: { sm: "text-xs", lg: { root: "text-lg", icon: "h-6" } }
      end
      instance = child.new

      expect(instance.select_options(size: :sm).classes(:icon)).to eq "h-3"
      expect(instance.select_options(size: :sm).classes).to eq "inline-flex bg-blue-500 text-xs"
      expect(child.new.classes).to eq "inline-flex bg-blue-500 text-lg"
      expect(child.new.classes(:icon)).to eq "h-6"
    end

    it "merges with extend_toggle, per state" do
      child = component(button) { extend_toggle :pill, off: "rounded-sm" }

      expect(child.new.classes).to eq "inline-flex bg-blue-500 text-base px-4 rounded-sm"
      expect(child.new.select_options(pill: true).classes).to eq "inline-flex bg-blue-500 text-base px-4 rounded-full"
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

      expect(button.option_values(:scheme)).to eq %i[blue red none]
    end

    it "reaches loaded subclasses when the parent is extended later" do
      extending = component(button)
      redefining = component(button) { variant :scheme, default: :gray, values: { gray: "bg-gray-500" } }
      expect(extending.new.classes).to eq "inline-flex bg-blue-500 text-base px-4"

      button.extend_variant :scheme, values: { brand: "bg-brand" }

      expect(extending.new.select_options(scheme: :brand).classes).to eq "inline-flex bg-brand text-base px-4"
      expect(redefining.option_values(:scheme)).to eq %i[gray none]
    end

    it "works when included directly into a ViewComponent" do
      plain = Class.new(ViewComponent::Base) do
        include Gustwave::Styling

        base "flex"
      end

      expect(plain.new.classes).to eq "flex"
    end

    it "drops a variant's classes when a subclass redeclares it as a plain option" do
      child = component(button) { option :scheme, default: :blue, values: %i[blue red none] }

      expect(child.new.select_options(scheme: :red).classes).to eq "inline-flex text-base px-4"
      expect(child.style_definition.to_h[:variants]).to eq [ :size ]
    end
  end

  describe "definition errors" do
    def resolve(&block)
      component(&block).style_definition
    end

    it "is raised when the definition is resolved, also when Gustwave isn't strict" do
      Gustwave.strict = false

      expect { resolve { variant :size, default: :xl, values: { md: "" } } }
        .to raise_error(Gustwave::DefinitionError, /default :xl of variant :size/)
    end

    it "is raised for per: toggles that don't cover the variant" do
      expect do
        resolve do
          variant :size, default: :md, values: { sm: "", md: "" }
          toggle :border, per: :size, values: { md: "ring-2", xl: "ring-4" }
        end
      end.to raise_error(Gustwave::DefinitionError, /no classes for :size \[:sm\].*unknown :size \[:xl\]/m)
    end

    it "is raised for per: on something that isn't a variant" do
      expect { resolve { toggle :border, per: :size, values: {} } }
        .to raise_error(Gustwave::DefinitionError, /per :size, which isn't a variant/)
    end

    it "is raised for unknown unless: options and values" do
      expect { resolve { base "flex", unless: { scheme: :none } } }
        .to raise_error(Gustwave::DefinitionError, /unless: :scheme/)
      expect do
        resolve do
          variant :size, default: :md, values: { md: "" }
          base "flex", unless: { size: :xl }
        end
      end.to raise_error(Gustwave::DefinitionError, /unknown values \[:xl\]/)
    end

    it "is raised for unknown unstyled options and values" do
      expect { resolve { unstyled scheme: :none } }
        .to raise_error(Gustwave::DefinitionError, /unstyled has scheme:, which isn't an option/)
      expect do
        resolve do
          variant :scheme, default: :blue, values: { blue: "" }
          unstyled scheme: :brand
        end
      end.to raise_error(Gustwave::DefinitionError, /unstyled has scheme: with unknown values \[:brand\]/)
    end

    it "is raised for unknown parts" do
      expect { resolve { base icon: "h-4" } }
        .to raise_error(Gustwave::DefinitionError, /unknown parts \[:icon\]/)
    end

    it "is raised for extending or removing something undefined" do
      expect { resolve { extend_variant :size, values: {} } }
        .to raise_error(Gustwave::DefinitionError, /variant :size isn't defined/)
      expect { resolve { toggle(:size); remove_variant :size } }
        .to raise_error(Gustwave::DefinitionError, /variant :size isn't defined \(it's a toggle\)/)
    end

    it "lets an extension finish before checking" do
      extended = component do
        variant :size, default: :md, values: { md: "" }
        toggle :border, per: :size, values: { md: "ring-2" }
      end
      extended.extend_variant :size, values: { xl: "" }
      extended.extend_toggle :border, values: { xl: "ring-4" }

      expect(extended.new.select_options(size: :xl, border: true).classes).to eq "ring-4"
    end

    it "is raised for extending a toggle that is a variant" do
      expect { resolve { variant(:size, default: :md, values: { md: "" }); extend_toggle :size, "ring-1" } }
        .to raise_error(Gustwave::DefinitionError, /toggle :size isn't defined \(it's a variant\)/)
    end
  end

  describe "readers" do
    it "describes the definition" do
      expect(button.style_definition.to_h).to eq(parts: %i[root icon], variants: %i[scheme size], toggles: [ :pill ])
    end
  end
end
