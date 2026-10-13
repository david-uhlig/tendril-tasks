require "rails_helper"

module Gustwave
  module Specs
    module Styleable
      # A generic base class
      class Base
        include Gustwave::Styleable
      end

      # A component with styles
      class Button < Base
        style :base, "bg-white text-gray-100"
      end

      # A derived component with styles
      class SpecializedButton < Button; end
    end
  end
end

RSpec.describe Gustwave::Styleable do
  let(:base) { Gustwave::Specs::Styleable::Base.new }
  let(:button) { Gustwave::Specs::Styleable::Button.new }
  let(:specialized_button) { Gustwave::Specs::Styleable::SpecializedButton.new }

  describe "#style" do
    it "does not leak data to parent components" do
      expect {
        base.styles(base: true)
      }.to raise_error(Gustwave::Styleable::InvalidStyleDefinitionError)
    end

    it "does set data for the component" do
      expect(button.styles(base: true)).to eq("bg-white text-gray-100")
    end

    it "does inherit data from child components" do
      expect(specialized_button.styles(base: true)).to eq("bg-white text-gray-100")
    end
  end
end
