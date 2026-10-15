# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::FetchOrFallbackHelper, type: :helper do
  it "returns an allowed value" do
    expect(helper.fetch_or_fallback(%i[button a], :a, :button)).to eq(:a)
  end

  it "raises for a value that isn't allowed" do
    expect { helper.fetch_or_fallback(%i[button a], :buton, :button) }
      .to raise_error(Gustwave::FetchOrFallbackHelper::InvalidValueError, /Did you mean :button\?/)
  end

  it "names the fallback in the error" do
    expect { helper.fetch_or_fallback(%i[button a], :div, :button) }
      .to raise_error(Gustwave::FetchOrFallbackHelper::InvalidValueError, /falls back to :button/)
  end

  context "in production" do
    before { allow(Rails.env).to receive(:production?).and_return(true) }

    it "returns the fallback for a value that isn't allowed" do
      expect(helper.fetch_or_fallback(%i[button a], :div, :button)).to eq(:button)
    end
  end
end
