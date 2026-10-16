require "rails_helper"
require "gustwave/test/styling_sandbox"

RSpec.describe Gustwave::Test::StylingSandbox do
  let(:parent) do
    Class.new(Gustwave::Component) do
      variant :color, default: :blue, values: { blue: "bg-blue-500" }
    end
  end
  let(:child) { Class.new(parent) }

  it "restores the declarations and reaches subclasses again" do
    described_class.isolate(parent) do
      parent.extend_variant :color, values: { brand: "bg-brand" }

      expect(child.option_values(:color)).to include(:brand)
    end

    expect(child.option_values(:color)).to eq %i[blue none]
  end

  it "restores a component without declarations of its own" do
    described_class.isolate(child) { child.toggle :pill, "rounded-full" }

    expect(child.option_definition.options.keys).to eq [ :color ]
  end

  it "restores after an error" do
    expect do
      described_class.isolate(parent) do
        parent.remove_variant :color
        raise "boom"
      end
    end.to raise_error("boom")

    expect(parent.option_default(:color)).to eq :blue
  end
end
