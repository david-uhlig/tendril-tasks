# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Active Storage direct uploads", type: :request do
  def upload(byte_size: 1.kilobyte, content_type: "image/png")
    post rails_direct_uploads_path,
         params: {
           blob: {
             filename: "image.png",
             byte_size: byte_size,
             checksum: Digest::MD5.base64digest("x"),
             content_type: content_type
           }
         },
         as: :json
  end

  it "requires authentication" do
    expect { upload }.not_to change(ActiveStorage::Blob, :count)
    expect(response).to have_http_status(:unauthorized)
  end

  it "forbids users who cannot edit rich text" do
    login_as(create(:user))

    expect { upload }.not_to change(ActiveStorage::Blob, :count)
    expect(response).to have_http_status(:forbidden)
  end

  it "allows editors" do
    login_as(create(:user, :editor))

    expect { upload }.to change(ActiveStorage::Blob, :count).by(1)
    expect(response).to have_http_status(:ok)
  end

  it "allows coordinators" do
    coordinator = create(:user)
    create(:task).coordinators << coordinator
    login_as(coordinator)

    expect { upload }.to change(ActiveStorage::Blob, :count).by(1)
    expect(response).to have_http_status(:ok)
  end

  it "rejects files larger than the limit" do
    login_as(create(:user, :admin))

    expect { upload(byte_size: RestrictedDirectUploadsController::MAX_BYTE_SIZE + 1) }
      .not_to change(ActiveStorage::Blob, :count)
    expect(response).to have_http_status(:content_too_large)
  end

  it "allows images, videos, audio files and PDFs" do
    login_as(create(:user, :editor))

    %w[ image/jpeg video/mp4 audio/mpeg application/pdf ].each do |content_type|
      expect { upload(content_type:) }.to change(ActiveStorage::Blob, :count).by(1)
      expect(response).to have_http_status(:ok)
    end
  end

  it "rejects other file types, including SVGs" do
    login_as(create(:user, :editor))

    [ "text/html", "image/svg+xml", "image/tiff", "application/zip", "" ].each do |content_type|
      expect { upload(content_type:) }.not_to change(ActiveStorage::Blob, :count)
      expect(response).to have_http_status(:unsupported_media_type)
    end
  end
end
