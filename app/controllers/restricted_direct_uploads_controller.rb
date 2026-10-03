# frozen_string_literal: true

# Restricts Active Storage direct uploads to users allowed to `:create, :direct_upload`
# (see `Ability`).
#
# Rails exposes `POST /rails/active_storage/direct_uploads` without
# authentication, which would let anyone store arbitrary files on the server.
# Lexxy uploads attachments through this endpoint, so it can't be removed.
# Instead, `config/routes.rb` routes the same path to this controller, which
# takes precedence over the route drawn by Active Storage.
class RestrictedDirectUploadsController < ActiveStorage::DirectUploadsController
  MAX_BYTE_SIZE = 10.megabytes

  # Images, videos, audio files and PDFs that browsers can display or play.
  # SVGs are deliberately left out, since they can embed scripts.
  ALLOWED_CONTENT_TYPES = %w[
    image/avif
    image/gif
    image/jpeg
    image/png
    image/webp

    video/mp4
    video/ogg
    video/quicktime
    video/webm

    audio/aac
    audio/flac
    audio/mp4
    audio/mpeg
    audio/ogg
    audio/wav
    audio/webm
    audio/x-m4a
    audio/x-wav

    application/pdf
  ].freeze

  before_action :authenticate_user!
  before_action { authorize! :create, :direct_upload }
  before_action :reject_oversized_upload
  before_action :reject_unsupported_content_type

  rescue_from CanCan::AccessDenied do
    head :forbidden
  end

  private

  def reject_unsupported_content_type
    head :unsupported_media_type unless params.dig(:blob, :content_type).in?(ALLOWED_CONTENT_TYPES)
  end

  def reject_oversized_upload
    head :content_too_large if params.dig(:blob, :byte_size).to_i > MAX_BYTE_SIZE
  end
end
