require "rails_helper"

module Gustwave
  module Specs
    module Themeable
      # A generic base class
      class Base
        include Gustwave::Themeable
      end

      # A component acting as a proxy for themed components
      #
      # Does not specify a default theme.
      class ThemeableButton < Base; end

      class ThemeableButtonWithCustomDefault < Base
        with_default_theme :any_theme_that_might_not_exist
      end

      # A theme for the ThemeableButton component
      #
      # Registers itself by specifying the class of the component it is for.
      #
      # Note: The theme does not have to inherit from ThemeableButton
      class DefaultTheme < Base
        theme_for(ThemeableButton)
        theme_for(ThemeableButton, as: :default_theme_alias)
      end

      # A theme for the ThemeableButton component
      #
      # Registers itself to it's parent class.
      class SpecialTheme < ThemeableButton
        theme_for_parent
        theme_for_parent(as: :special_theme_on_parent_alias)
      end
    end
  end
end

RSpec.describe Gustwave::Themeable do
  let(:base) { Gustwave::Specs::Themeable::Base.new }
  let(:themeable_button) { Gustwave::Specs::Themeable::ThemeableButton.new }
  let(:themeable_button_with_custom_default) do Gustwave::Specs::Themeable::ThemeableButtonWithCustomDefault.new
  end
  let(:default_theme) { Gustwave::Specs::Themeable::DefaultTheme.new }

  describe "#theme_for" do
    it "registers DefaultTheme as default_theme on Button" do
      expect(themeable_button.themed_component(:default_theme)).to eq(Gustwave::Specs::Themeable::DefaultTheme)
    end

    it "registers DefaultTheme as default_theme_alias on Button" do
      expect(themeable_button.themed_component(:default_theme_alias)).to eq(Gustwave::Specs::Themeable::DefaultTheme)
    end

    it "registers default_theme as default theme" do
      # Because it is the first theme registered with the class
      expect(themeable_button.default_theme).to eq(:default_theme)
    end

    it "does not leak data to parent components" do
      expect(base.themes).to be_empty
      expect(base.default_theme).to be_nil
    end

    it "does not leak data to child components" do
      expect(default_theme.themes).to be_empty
      expect(default_theme.default_theme).to be_nil
    end
  end

  describe "#theme_for_parent" do
    it "registers SpecialTheme as special_theme on Button" do
      expect(themeable_button.themed_component(:special_theme)).to eq(Gustwave::Specs::Themeable::SpecialTheme)
    end

    it "registers SpecialTheme as special_theme_on_parent_alias on Button" do
      expect(themeable_button.themed_component(:special_theme_on_parent_alias)).to eq(Gustwave::Specs::Themeable::SpecialTheme)
    end
  end

  describe "#with_default_theme" do
    it "sets the default theme" do
      expect(themeable_button_with_custom_default.default_theme).to eq(:any_theme_that_might_not_exist)
    end

    it "is not required that the theme exists" do
      expect {
        themeable_button_with_custom_default.themed_component(:any_theme_that_might_not_exist)
      }.to raise_error(Gustwave::Themeable::ThemeNotFoundError)
    end
  end

  describe ".themed_component" do
    it "returns the theme component when it exists" do
      expect(themeable_button.default_theme).not_to eq(:special_theme_on_parent_alias)
      expect(themeable_button.themed_component(:special_theme_on_parent_alias)).to eq(Gustwave::Specs::Themeable::SpecialTheme)
    end

    context "when the theme does not exist" do
      it "raises an ArgumentError outside of production" do
        expect {
          themeable_button.themed_component(:some_non_existent_theme)
        }.to raise_error(Gustwave::Themeable::ThemeNotFoundError)
      end

      it "returns the default theme component in production" do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        expect(themeable_button.themed_component(:some_non_existent_theme)).to eq(Gustwave::Specs::Themeable::DefaultTheme)
      end
    end
  end
end
