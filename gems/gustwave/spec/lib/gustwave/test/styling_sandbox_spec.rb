require "rails_helper"
require "gustwave/test/styling_sandbox"

RSpec.describe Gustwave::Test::StylingSandbox do
  let(:parent) do
    Class.new(Gustwave::Component) do
      variant :scheme, default: :blue, values: { blue: "bg-blue-500" }
    end
  end
  let(:child) { Class.new(parent) }

  it "restores the declarations and reaches subclasses again" do
    described_class.isolate(parent) do
      parent.extend_variant :scheme, values: { brand: "bg-brand" }

      expect(child.variant_values(:scheme)).to include(:brand)
    end

    expect(child.variant_values(:scheme)).to eq %i[blue none]
  end

  it "restores a component without declarations of its own" do
    described_class.isolate(child) { child.toggle :pill, "rounded-full" }

    expect(child.style_definition.options.keys).to eq [ :scheme ]
  end

  it "restores after an error" do
    expect do
      described_class.isolate(parent) do
        parent.remove_variant :scheme
        raise "boom"
      end
    end.to raise_error("boom")

    expect(parent.variant_default(:scheme)).to eq :blue
  end
end
