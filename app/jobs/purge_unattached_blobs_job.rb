# frozen_string_literal: true

# Purges blobs that were uploaded but never attached, e.g. direct uploads from
# rich text editors whose form was abandoned.
class PurgeUnattachedBlobsJob < ApplicationJob
  # Leaves enough time to finish editing a form with freshly uploaded files.
  MIN_AGE = 2.days

  def perform
    ActiveStorage::Blob.unattached
                       .where(created_at: ..MIN_AGE.ago)
                       .find_each(&:purge_later)
  end
end
