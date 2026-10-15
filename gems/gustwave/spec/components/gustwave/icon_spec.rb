# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Icon, type: :component do
  def theme_for(**options)
    described_class.new(:home, **options).send(:icon_path)
  end

  it "loads outline icons by default" do
    expect(theme_for).to end_with("gustwave/icons/outline/home.svg")
  end

  it "loads solid icons" do
    expect(theme_for(theme: :solid)).to end_with("gustwave/icons/solid/home.svg")
  end

  it "raises for an unknown theme" do
    expect { described_class.new(:home, theme: :duotone) }
      .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :duotone for :theme/)
  end
end
