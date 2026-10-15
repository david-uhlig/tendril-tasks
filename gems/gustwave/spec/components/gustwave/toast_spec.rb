# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Toast, type: :component do
  it "is dismissible by default" do
    expect(described_class.new("text")).to be_dismissible
  end

  [ nil, true, "true" ].each do |dismissible|
    it "is dismissible with dismissible: #{dismissible.inspect}" do
      expect(described_class.new("text", dismissible:)).to be_dismissible
    end
  end

  [ false, "false", "0" ].each do |dismissible|
    it "isn't dismissible with dismissible: #{dismissible.inspect}" do
      expect(described_class.new("text", dismissible:)).not_to be_dismissible
    end
  end
end
