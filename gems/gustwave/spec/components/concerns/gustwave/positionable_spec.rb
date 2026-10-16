require "rails_helper"

RSpec.describe Gustwave::Positionable do
  let(:component) do
    Class.new(Gustwave::Component) do
      include Gustwave::Positionable

      def self.name = "PositionableExample"

      def initialize(position: Gustwave::Options::DEFAULT)
        select_options(position:)
      end
    end
  end

  def classes_for(position)
    component.new(position:).classes.to_s.split
  end

  it "declares a position for every vertical and horizontal anchor, the aliases, and :none" do
    expect(component.option_values(:position)).to contain_exactly(
      :top_left, :top_center, :top_right,
      :middle_left, :middle_center, :middle_right,
      :bottom_left, :bottom_center, :bottom_right,
      :top, :middle, :center, :bottom,
      :none
    )
  end

  it "defaults to :none, which adds no classes" do
    expect(component.option_default(:position)).to eq :none
    expect(component.new.classes).to be_nil
  end

  described_class::POSITIONS.each_key do |position|
    it "anchors #{position.inspect} on exactly one vertical and one horizontal edge" do
      classes = classes_for(position)

      expect(classes).to include "absolute"
      expect(classes.grep(/\A(top|bottom)-/).size).to eq(1), "expected one vertical anchor in #{classes}"
      expect(classes.grep(/\A(left|right)-/).size).to eq(1), "expected one horizontal anchor in #{classes}"
      expect(classes.grep(/\A-?translate-y-/).size).to eq(1), "expected one vertical translation in #{classes}"
      expect(classes.grep(/\A-?translate-x-/).size).to eq(1), "expected one horizontal translation in #{classes}"
    end
  end

  it "centers the component on the chosen edges" do
    expect(classes_for(:top_left)).to contain_exactly("absolute", "top-0", "-translate-y-1/2", "left-0", "-translate-x-1/2")
    expect(classes_for(:middle_center)).to contain_exactly("absolute", "top-1/2", "-translate-y-1/2", "left-1/2", "-translate-x-1/2")
    expect(classes_for(:bottom_right)).to contain_exactly("absolute", "bottom-0", "translate-y-1/2", "right-0", "translate-x-1/2")
  end

  described_class::ALIASES.each do |alias_name, position|
    it "resolves #{alias_name.inspect} to #{position.inspect}" do
      expect(classes_for(alias_name)).to eq classes_for(position)
    end
  end

  it "can be included without Gustwave::Component" do
    standalone = Class.new { include Gustwave::Positionable }

    expect(standalone.option_values(:position)).to include(:top_left, :none)
  end
end
