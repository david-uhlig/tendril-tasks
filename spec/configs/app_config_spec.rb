# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppConfig, type: :config do
  subject(:config) { described_class.new }

  describe "#git_commit" do
    it "returns the configured commit" do
      config.git_commit = "abc1234"
      expect(config.git_commit).to eq("abc1234")
    end

    it "is blank outside of development when not configured" do
      expect(config.git_commit).to be_nil
    end

    context "in development" do
      before { allow(Rails.env).to receive(:development?).and_return(true) }

      it "falls back to the checked out commit" do
        expect(config.git_commit).to eq(`git rev-parse --short HEAD`.strip)
      end

      it "runs git only once" do
        allow(IO).to receive(:popen).and_call_original
        2.times { config.git_commit }
        expect(IO).to have_received(:popen).once
      end

      it "prefers the configured commit" do
        config.git_commit = "abc1234"
        expect(config.git_commit).to eq("abc1234")
      end

      it "is blank when git is unavailable" do
        allow(IO).to receive(:popen).and_raise(Errno::ENOENT)
        expect(config.git_commit).to be_nil
      end
    end
  end

  describe "#delete_confirm_cooldown" do
    it "is disabled in the test environment" do
      expect(config.delete_confirm_cooldown).to eq(0)
    end

    it "can be configured through the environment" do
      with_env("APP_DELETE_CONFIRM_COOLDOWN" => "5") do
        expect(described_class.new.delete_confirm_cooldown).to eq(5)
      end
    end
  end
end
