# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidQueueConfig, type: :config do
  describe "#in_puma" do
    it "defaults to false" do
      expect(described_class.new.in_puma).to be(false)
    end

    it "is read from SOLID_QUEUE_IN_PUMA" do
      with_env("SOLID_QUEUE_IN_PUMA" => "true") do
        expect(described_class.new.in_puma).to be(true)
      end
    end

    it "is false when SOLID_QUEUE_IN_PUMA is false" do
      with_env("SOLID_QUEUE_IN_PUMA" => "false") do
        expect(described_class.new.in_puma).to be(false)
      end
    end
  end

  describe "#mode" do
    it "defaults to fork" do
      expect(described_class.new.mode).to eq("fork")
    end

    it "is read from SOLID_QUEUE_MODE" do
      with_env("SOLID_QUEUE_MODE" => "async") do
        expect(described_class.new.mode).to eq("async")
      end
    end

    it "raises on an unknown mode" do
      with_env("SOLID_QUEUE_MODE" => "threads") do
        expect { described_class.new }.to raise_error(Anyway::Config::ValidationError, /SOLID_QUEUE_MODE/)
      end
    end
  end

  describe "#queue_database_pool" do
    it "is nil in fork mode, to use the default pool" do
      config = described_class.new(in_puma: true, mode: "fork")
      expect(config.queue_database_pool).to be_nil
    end

    it "is nil in async mode outside of Puma" do
      config = described_class.new(in_puma: false, mode: "async")
      expect(config.queue_database_pool).to be_nil
    end

    it "is 10 in async mode inside Puma" do
      config = described_class.new(in_puma: true, mode: "async")
      expect(config.queue_database_pool).to eq(10)
    end

    it "is the configured pool in async mode inside Puma" do
      config = described_class.new(in_puma: true, mode: "async", db_pool: 20)
      expect(config.queue_database_pool).to eq(20)
    end

    it "is the configured pool in fork mode" do
      config = described_class.new(in_puma: true, mode: "fork", db_pool: 20)
      expect(config.queue_database_pool).to eq(20)
    end

    it "reads the pool from SOLID_QUEUE_DB_POOL" do
      with_env("SOLID_QUEUE_DB_POOL" => "15") do
        expect(described_class.new.queue_database_pool).to eq(15)
      end
    end
  end
end
