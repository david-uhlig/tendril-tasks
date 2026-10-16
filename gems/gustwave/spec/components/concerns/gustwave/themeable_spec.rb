require "rails_helper"

module Gustwave
  module Specs
    module Themeable
      # A generic base class
      class Base
        include Gustwave::Themeable
      end

      # A theme for the ThemeableButton component
      #
      # Note: The theme does not have to inherit from ThemeableButton
      class DefaultTheme < Base; end

      # Another theme for the ThemeableButton component
      class SpecialTheme < Base; end

      # A component acting as a proxy for themed components
      #
      # Does not specify a default theme.
      class ThemeableButton < Base
        register_theme :default_theme, "Gustwave::Specs::Themeable::DefaultTheme"
        register_theme :default_theme_alias, "Gustwave::Specs::Themeable::DefaultTheme"
        register_theme :special_theme, "Gustwave::Specs::Themeable::SpecialTheme"
      end

      class ThemeableButtonWithCustomDefault < Base
        register_theme :default_theme, "Gustwave::Specs::Themeable::DefaultTheme"
        register_theme :special_theme, "Gustwave::Specs::Themeable::SpecialTheme"
        with_default_theme :special_theme
      end

      # Inherits the themes of ThemeableButton and adds its own
      class ExtendedThemeableButton < ThemeableButton
        register_theme :extended_theme, "Gustwave::Specs::Themeable::SpecialTheme"
      end
    end
  end
end

RSpec.describe Gustwave::Themeable do
  let(:base) { Gustwave::Specs::Themeable::Base.new }
  let(:themeable_button) { Gustwave::Specs::Themeable::ThemeableButton.new }
  let(:themeable_button_with_custom_default) { Gustwave::Specs::Themeable::ThemeableButtonWithCustomDefault.new }
  let(:extended_themeable_button) { Gustwave::Specs::Themeable::ExtendedThemeableButton.new }

  describe ".register_theme" do
    it "registers the theme under its name" do
      expect(themeable_button.themed_component(:default_theme)).to eq(Gustwave::Specs::Themeable::DefaultTheme)
    end

    it "registers the same theme under several names" do
      expect(themeable_button.themed_component(:default_theme_alias)).to eq(Gustwave::Specs::Themeable::DefaultTheme)
    end

    it "resolves the class name when the theme is requested" do
      klass = Class.new(Gustwave::Specs::Themeable::Base) do
        register_theme :not_yet_defined, "Gustwave::Specs::Themeable::NotYetDefinedTheme"
      end
      stub_const("Gustwave::Specs::Themeable::NotYetDefinedTheme", Class.new)

      expect(klass.new.themed_component(:not_yet_defined)).to eq(Gustwave::Specs::Themeable::NotYetDefinedTheme)
    end

    it "inherits the themes of the parent class" do
      expect(extended_themeable_button.themed_component(:default_theme)).to eq(Gustwave::Specs::Themeable::DefaultTheme)
      expect(extended_themeable_button.themed_component(:extended_theme)).to eq(Gustwave::Specs::Themeable::SpecialTheme)
    end

    it "does not leak themes to the parent class" do
      expect(Gustwave::Specs::Themeable::ThemeableButton.themes).not_to have_key(:extended_theme)
      expect(Gustwave::Specs::Themeable::Base.themes).to be_empty
    end
  end

  describe ".themes" do
    it "returns the theme classes by name" do
      expect(Gustwave::Specs::Themeable::ThemeableButton.themes).to eq(
        default_theme: Gustwave::Specs::Themeable::DefaultTheme,
        default_theme_alias: Gustwave::Specs::Themeable::DefaultTheme,
        special_theme: Gustwave::Specs::Themeable::SpecialTheme
      )
    end
  end

  describe "#default_theme" do
    it "defaults to the first registered theme" do
      expect(themeable_button.default_theme).to eq(:default_theme)
    end

    it "is set by .with_default_theme" do
      expect(themeable_button_with_custom_default.default_theme).to eq(:special_theme)
    end

    it "is nil without registered themes" do
      expect(base.default_theme).to be_nil
    end
  end

  describe "#themed_component" do
    it "returns the default theme for nil" do
      expect(themeable_button_with_custom_default.themed_component(nil)).to eq(Gustwave::Specs::Themeable::SpecialTheme)
    end

    it "returns the default theme for DEFAULT" do
      expect(themeable_button_with_custom_default.themed_component(Gustwave::Options::DEFAULT))
        .to eq(Gustwave::Specs::Themeable::SpecialTheme)
    end

    context "when the theme does not exist" do
      it "raises a ThemeNotFoundError when Gustwave is strict" do
        expect {
          themeable_button.themed_component(:some_non_existent_theme)
        }.to raise_error(Gustwave::Themeable::ThemeNotFoundError, /Expected one of: \[:default_theme, :default_theme_alias, :special_theme\]/)
      end

      it "returns the default theme when Gustwave isn't strict" do
        Gustwave.strict = false
        expect(themeable_button_with_custom_default.themed_component(:some_non_existent_theme)).to eq(Gustwave::Specs::Themeable::SpecialTheme)
      end

      it "raises a ThemeNotFoundError without registered themes when Gustwave isn't strict" do
        Gustwave.strict = false
        expect { base.themed_component(:some_non_existent_theme) }.to raise_error(Gustwave::Themeable::ThemeNotFoundError, /No themes registered/)
      end
    end
  end
end
