require "rails_helper"

RSpec.describe Gustwave::Options do
  def component(parent = Gustwave::Component, &block)
    Class.new(parent, &block)
  end

  let(:linked) do
    component do
      option :tag, default: :a, values: %i[a button]
      option :rel, default: :none, values: %i[none nofollow]
    end
  end

  # Options of variants and toggles, from Gustwave::Styling
  let(:button) do
    component do
      variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
      toggle :pill, "rounded-full"
    end
  end

  describe "options" do
    it "picks a value from its values" do
      expect(linked.option_values(:tag)).to eq %i[a button]
      expect(linked.new.option_value(:tag)).to eq :a
      expect(linked.new.select_options(tag: :button).option_value(:tag)).to eq :button
    end

    it "has no implicit :none" do
      expect { linked.new.select_options(tag: :none) }.to raise_error(Gustwave::Options::UnknownValueError)
      expect(linked.option_values(:rel)).to eq %i[none nofollow]
    end

    it "converts strings and numbers to symbols" do
      stroked = component { option :stroke, default: 1.5, values: [ 1.5, 2 ] }

      expect(stroked.option_default(:stroke)).to eq :"1.5"
      expect(stroked.new.select_options(stroke: "2").option_value(:stroke)).to eq :"2"
    end

    it "adds no classes" do
      expect(linked.new.select_options(tag: :button).classes).to be_nil
    end

    it "is shared by variants, with an implicit :none, and toggles, as booleans" do
      expect(button.option_values(:size)).to eq %i[sm md none]
      expect(button.new.option_value(:pill)).to be false
      expect(button.new.select_options(pill: "true").option_value(:pill)).to be true
    end

    it "works when included directly into a ViewComponent" do
      plain = Class.new(ViewComponent::Base) do
        include Gustwave::Options

        option :tag, default: :div, values: %i[div span]
      end

      expect(plain.new.select_options(tag: :span).option_value(:tag)).to eq :span
      expect(plain).not_to respond_to(:variant)
    end
  end

  describe "#select_options" do
    it "merges repeated calls" do
      instance = linked.new.select_options(tag: :button).select_options(rel: :nofollow)

      expect(instance.option_value(:tag)).to eq :button
      expect(instance.option_value(:rel)).to eq :nofollow
    end

    it "treats nil and DEFAULT as the default" do
      instance = linked.new.select_options(tag: nil, rel: Gustwave::Options::DEFAULT)

      expect(instance.option_value(:tag)).to eq :a
      expect(instance.option_value(:rel)).to eq :none
    end

    it "raises for unknown options and values, with suggestions" do
      expect { linked.new.select_options(tagg: :a) }
        .to raise_error(Gustwave::Options::UnknownOptionError, /no option :tagg. Did you mean :tag\?/)
      expect { linked.new.select_options(tag: :buton) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Did you mean :button\?.*falls back to :a/m)
    end

    context "in production" do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it "ignores unknown options and falls back to the default for unknown values" do
        instance = linked.new.select_options(tga: :button, tag: :div)

        expect(instance.option_value(:tag)).to eq :a
      end

      it "raises when Gustwave is strict" do
        Gustwave.strict = true

        expect { linked.new.select_options(tag: :div) }.to raise_error(Gustwave::Options::UnknownValueError)
      end
    end

    it "falls back outside production when Gustwave isn't strict" do
      Gustwave.strict = false
      instance = linked.new.select_options(tga: :button, tag: :div)

      expect(instance.option_value(:tag)).to eq :a
    end
  end

  describe "#option_value" do
    it "returns the value in effect" do
      expect(linked.new.select_options(tag: :button).option_value("tag")).to eq :button
    end

    it "lets call-time options override the selection" do
      instance = linked.new.select_options(tag: :button)

      expect(instance.option_value(:tag, tag: :a)).to eq :a
      expect(instance.option_value(:tag)).to eq :button
    end

    it "raises for unknown options" do
      expect { linked.new.option_value(:colour) }.to raise_error(Gustwave::Options::UnknownOptionError)
    end
  end

  describe "derived values" do
    let(:sized) do
      component(button) { derive :icon_size, from: :size, values: { sm: :xs, md: :sm } }
    end

    it "returns the value for the option's value in effect" do
      expect(sized.new.derived_value(:icon_size)).to eq :sm
      expect(sized.new.select_options(size: :sm).derived_value("icon_size")).to eq :xs
    end

    it "derives from plain options" do
      leveled = component(linked) { derive :level, from: :tag, values: { a: 1, button: 2 } }

      expect(leveled.new.select_options(tag: :button).derived_value(:level)).to eq 2
    end

    it "takes overrides for one call" do
      expect(sized.new.derived_value(:icon_size, size: :sm)).to eq :xs
    end

    it "returns nil for an implicit :none it doesn't cover" do
      expect(sized.new.select_options(size: :none).derived_value(:icon_size)).to be_nil
    end

    it "adds no classes" do
      expect(sized.new.classes).to eq "text-base"
    end

    it "raises for unknown derived values, also in production" do
      allow(Rails.env).to receive(:production?).and_return(true)

      expect { sized.new.derived_value(:icon_sise) }
        .to raise_error(Gustwave::Options::UnknownDerivedValueError, /no derived value :icon_sise. Did you mean :icon_size\?/)
    end

    it "is extended and removed in subclasses without changing the parent" do
      child = component(sized) do
        extend_variant :size, values: { lg: "text-lg" }
        extend_derived :icon_size, values: { lg: :md }
      end
      removed = component(sized) { remove_derived :icon_size }

      expect(child.new.select_options(size: :lg).derived_value(:icon_size)).to eq :md
      expect { removed.new.derived_value(:icon_size) }.to raise_error(Gustwave::Options::UnknownDerivedValueError)
      expect(sized.option_definition.derived_values[:icon_size].values.keys).to eq %i[sm md]
    end
  end

  describe "inheritance" do
    it "extends an option with more values and another default" do
      extended = component(linked) { extend_option :tag, default: :span, values: %i[div span] }

      expect(extended.option_values(:tag)).to eq %i[a button div span]
      expect(extended.new.option_value(:tag)).to eq :span
      expect(linked.option_values(:tag)).to eq %i[a button]
    end

    it "replaces a redeclared option in place" do
      child = component(linked) { option :tag, default: :div, values: %i[div] }

      expect(child.option_definition.options.keys).to eq %i[tag rel]
      expect(child.option_values(:tag)).to eq %i[div]
    end

    it "removes an option" do
      child = component(linked) { remove_option :rel }

      expect { child.new.option_value(:rel) }.to raise_error(Gustwave::Options::UnknownOptionError)
    end

    it "reaches loaded subclasses when the parent is extended later" do
      child = component(linked)
      expect(child.option_values(:tag)).to eq %i[a button]

      linked.extend_option :tag, values: %i[span]

      expect(child.option_values(:tag)).to eq %i[a button span]
    end
  end

  describe "definition errors" do
    def resolve(&block)
      component(&block).option_definition
    end

    it "is raised when the definition is resolved, also in production" do
      allow(Rails.env).to receive(:production?).and_return(true)

      expect { resolve { option :tag, default: :p, values: %i[a] } }
        .to raise_error(Gustwave::DefinitionError, /default :p of option :tag isn't one of its values \[:a\]/)
    end

    it "is raised for derived values that don't cover the option" do
      expect do
        resolve do
          variant :size, default: :md, values: { sm: "", md: "" }
          derive :icon_size, from: :size, values: { md: :sm, xl: :lg }
        end
      end.to raise_error(Gustwave::DefinitionError, /derived :icon_size has no values for :size \[:sm\].*unknown :size \[:xl\]/m)
    end

    it "is raised for values derived from a toggle or nothing" do
      expect { resolve { toggle :pill; derive :radius, from: :pill, values: {} } }
        .to raise_error(Gustwave::DefinitionError, /derived :radius is from :pill, which isn't a variant or option/)
      expect { resolve { derive :radius, from: :size, values: {} } }
        .to raise_error(Gustwave::DefinitionError, /derived :radius is from :size/)
    end

    it "is raised when an extension of the option isn't covered by its derived values" do
      parent = component do
        variant :size, default: :md, values: { md: "" }
        derive :icon_size, from: :size, values: { md: :sm }
      end
      child = component(parent)
      parent.option_definition
      child.option_definition

      parent.extend_variant :size, values: { xl: "" }

      expect { child.option_definition }
        .to raise_error(Gustwave::DefinitionError, /derived :icon_size has no values for :size \[:xl\]/)
    end

    it "is raised for extending or removing something undefined" do
      expect { resolve { extend_option :tag, values: %i[a] } }
        .to raise_error(Gustwave::DefinitionError, /option :tag isn't defined/)
      expect { resolve { toggle :tag; extend_option :tag, values: %i[a] } }
        .to raise_error(Gustwave::DefinitionError, /option :tag isn't defined \(it's a toggle\)/)
      expect { resolve { variant :tag, default: :a, values: { a: "" }; remove_option :tag } }
        .to raise_error(Gustwave::DefinitionError, /option :tag isn't defined \(it's a variant\)/)
      expect { resolve { remove_derived :level } }
        .to raise_error(Gustwave::DefinitionError, /derived :level isn't defined/)
    end
  end

  describe "readers" do
    it "describes the definition" do
      expect(linked.option_default(:tag)).to eq :a
      expect(linked.new.option_default(:rel)).to eq :none
      expect(component(button) { derive :icon_size, from: :size, values: { sm: :xs, md: :sm } }.option_definition.to_h).to eq(
        options: {
          size: { kind: :variant, default: :md, values: %i[sm md none] },
          pill: { kind: :toggle, default: false, values: [ false, true ] }
        },
        derived: { icon_size: { from: :size, values: %i[sm md] } }
      )
    end

    it "raises for unknown options, and for the values of a toggle" do
      expect { linked.option_default(:colour) }.to raise_error(Gustwave::Options::UnknownOptionError)
      expect { button.option_values(:pill) }.to raise_error(Gustwave::Options::UnknownOptionError)
    end
  end

  describe "DEFAULT" do
    it "is a named sentinel" do
      expect(Gustwave::Options::DEFAULT.inspect).to eq "DEFAULT"
      expect(Gustwave::Options::DEFAULT).to be_frozen
    end

    it "resolves to the default of the instance's class" do
      parent = component do
        option :tag, default: :a, values: %i[a]

        # A block's constants resolve lexically, so a class built with
        # Class.new names DEFAULT in full. A class body finds it unqualified.
        def initialize(tag: Gustwave::Options::DEFAULT)
          select_options(tag:)
        end
      end
      child = component(parent) { extend_option :tag, default: :button, values: %i[button] }

      expect(parent.new.option_value(:tag)).to eq :a
      expect(child.new.option_value(:tag)).to eq :button
    end
  end
end
