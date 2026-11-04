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

  describe ".deprecator" do
    it "names Gustwave and the next minor release in its warnings" do
      stub_const("Gustwave::VERSION", "0.4.2")
      deprecator = described_class.instance_variable_get(:@deprecator)
      described_class.remove_instance_variable(:@deprecator) if deprecator

      expect(described_class.deprecator.deprecation_horizon).to eq("0.5")
      expect(described_class.deprecator.gem_name).to eq("Gustwave")
    ensure
      described_class.instance_variable_set(:@deprecator, deprecator)
    end

    it "is registered with the app's deprecators" do
      expect(Rails.application.deprecators[:gustwave]).to be(described_class.deprecator)
    end

    it "warns" do
      expect { described_class.deprecator.warn("`old:` is deprecated") }
        .to output(/DEPRECATION WARNING: `old:` is deprecated/).to_stderr
    end

    it "names the removal release for a deprecated method" do
      klass = Class.new do
        def self.name = "Old"
        def old = :still_works
      end
      described_class.deprecator.deprecate_methods(klass, old: "use `new` instead")

      expect { expect(klass.new.old).to eq(:still_works) }
        .to output(/old is deprecated and will be removed from Gustwave \d+\.\d+ \(use `new` instead\)/).to_stderr
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
