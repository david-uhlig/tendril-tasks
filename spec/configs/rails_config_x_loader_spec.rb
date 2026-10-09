# frozen_string_literal: true

require "rails_helper"

RSpec.describe RailsConfigXLoader, type: :config do
  before do
    allow(Rails.application.config.x).to receive(:example).and_return(
      ActiveSupport::OrderedOptions[value: "configured"]
    )
  end

  it "loads from `config.x` before credentials and ENV-vars" do
    expect(Anyway.loaders.keys).to eq(%i[yml rails_config_x credentials env])
  end

  it "loads `config.x.<config name>` when the config opts in" do
    expect(described_class.call(name: :example, rails_config_x: true)).to eq(value: "configured")
  end

  it "loads nothing otherwise" do
    expect(described_class.call(name: :example)).to eq({})
  end
end
