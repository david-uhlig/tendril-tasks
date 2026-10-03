# frozen_string_literal: true

require "rails_helper"

RSpec.describe PurgeUnattachedBlobsJob, type: :job do
  include ActiveJob::TestHelper

  def create_blob(created_at:)
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("x"), filename: "file.txt"
    ).tap { it.update_column(:created_at, created_at) }
  end

  it "purges old unattached blobs" do
    old_blob = create_blob(created_at: 3.days.ago)

    perform_enqueued_jobs { described_class.perform_now }

    expect(ActiveStorage::Blob.exists?(old_blob.id)).to be false
  end

  it "keeps recent unattached blobs" do
    recent_blob = create_blob(created_at: 1.hour.ago)

    perform_enqueued_jobs { described_class.perform_now }

    expect(ActiveStorage::Blob.exists?(recent_blob.id)).to be true
  end

  it "keeps attached blobs" do
    attached_blob = create_blob(created_at: 3.days.ago)
    ActiveStorage::Attachment.create!(name: "attachment", record: Setting.create!(key: "test"), blob: attached_blob)

    perform_enqueued_jobs { described_class.perform_now }

    expect(ActiveStorage::Blob.exists?(attached_blob.id)).to be true
  end
end
