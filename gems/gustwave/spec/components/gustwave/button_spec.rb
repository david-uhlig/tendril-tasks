require "rails_helper"

RSpec.describe Gustwave::Button do
  describe ".for" do
    it "returns the theme class for every registered theme" do
      described_class.themes.each do |theme_name, theme_class|
        expect(described_class.for(theme_name)).to eq(theme_class)
      end
    end

    it "resolves aliases to their class" do
      expect(described_class.for(:outline)).to eq(Gustwave::Buttons::DefaultOutline)
      expect(described_class.for(:colored_shadow)).to eq(Gustwave::Buttons::GradientMonochromeColoredShadow)
    end

    it "returns the default theme class for nil" do
      expect(described_class.for(nil)).to eq(Gustwave::Buttons::Default)
    end

    it "returns the default theme class for Gustwave::Options::DEFAULT" do
      expect(described_class.for(Gustwave::Options::DEFAULT)).to eq(Gustwave::Buttons::Default)
    end

    it "raises a ThemeNotFoundError listing the themes when Gustwave is strict" do
      Gustwave.strict = true
      expect { described_class.for(:typo) }.to raise_error(Gustwave::Themeable::ThemeNotFoundError, /Expected one of:.*:gradient_duotone/)
    end

    it "returns the default theme class for an unknown theme when Gustwave isn't strict" do
      Gustwave.strict = false
      expect(described_class.for(:typo)).to eq(Gustwave::Buttons::Default)
    end

    context "with a subclass" do
      let(:subclass) do
        Class.new(described_class) do
          register_theme :x, "Gustwave::Buttons::Inline"
        end
      end

      it "inherits the themes of Gustwave::Button" do
        expect(subclass.for(:outline)).to eq(Gustwave::Buttons::DefaultOutline)
      end

      it "resolves its own theme" do
        expect(subclass.for(:x)).to eq(Gustwave::Buttons::Inline)
      end

      it "does not register its theme on Gustwave::Button" do
        subclass
        expect(described_class.themes).not_to have_key(:x)
      end
    end
  end

  describe ".new" do
    it "is private" do
      expect { described_class.new }.to raise_error(NoMethodError, /private method .new. called/)
    end
  end
end
