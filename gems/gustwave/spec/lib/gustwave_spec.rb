# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave do
  describe ".strict?" do
    def in_env(name)
      allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new(name))
    end

    it "is strict in development and test by default" do
      in_env("development")
      expect(described_class).to be_strict

      in_env("test")
      expect(described_class).to be_strict
    end

    it "isn't strict in production or any other environment by default" do
      in_env("production")
      expect(described_class).not_to be_strict

      in_env("staging")
      expect(described_class).not_to be_strict
    end

    it "is strict in another environment when set" do
      in_env("staging")
      described_class.strict = true
      expect(described_class).to be_strict
    end

    it "isn't strict in test when unset" do
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
