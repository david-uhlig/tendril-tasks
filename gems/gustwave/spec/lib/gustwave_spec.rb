# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave do
  describe ".strict?" do
    it "is strict outside production by default" do
      expect(described_class).to be_strict
    end

    it "isn't strict in production by default" do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect(described_class).not_to be_strict
    end

    it "is strict in production when set" do
      allow(Rails.env).to receive(:production?).and_return(true)
      described_class.strict = true
      expect(described_class).to be_strict
    end

    it "isn't strict outside production when unset" do
      described_class.strict = false
      expect(described_class).not_to be_strict
    end

    it "restores the default when set to nil" do
      described_class.strict = false
      described_class.strict = nil
      expect(described_class).to be_strict
    end
  end

  describe "config.gustwave.strict" do
    it "sets Gustwave.strict when the app initializes" do
      initializer = Gustwave::Engine.initializers.find { it.name == "gustwave.strict" }
      app = Rails.application
      allow(app.config.gustwave).to receive(:strict).and_return(false)

      initializer.run(app)

      expect(described_class).not_to be_strict
    end
  end
end
