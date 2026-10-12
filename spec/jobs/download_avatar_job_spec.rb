# frozen_string_literal: true

require "rails_helper"

RSpec.describe DownloadAvatarJob, :webmock, type: :job do
  let(:avatar_url) { "https://chat.example.com/avatar/john.smith" }
  let(:request_url) { "#{avatar_url}?format=png&size=#{described_class::SIZE}" }
  let(:user) { create(:user, avatar_url:) }
  let(:png) { file_fixture("avatar.png").binread }

  def stub_avatar(url = request_url, body: png, status: 200, headers: { "Content-Type" => "image/png" })
    stub_request(:get, url).to_return(status:, body:, headers:)
  end

  def stored_image
    Vips::Image.new_from_buffer(user.avatar.download, "")
  end

  it "stores the avatar as a square WebP image" do
    stub_avatar

    described_class.perform_now(user)

    expect(user.avatar).to be_attached
    expect(user.avatar.content_type).to eq("image/webp")
    expect([ stored_image.width, stored_image.height ]).to eq([ described_class::SIZE, described_class::SIZE ])
  end

  it "keeps the query of the avatar URL" do
    user.update!(avatar_url: "#{avatar_url}?etag=abc")
    stub_avatar("#{avatar_url}?etag=abc&format=png&size=#{described_class::SIZE}")

    described_class.perform_now(user)

    expect(user.avatar).to be_attached
  end

  it "skips SVG avatars, which Active Storage refuses to load" do
    stub_avatar(body: file_fixture("avatar.svg").read, headers: { "Content-Type" => "image/svg+xml" })

    expect { described_class.perform_now(user) }.not_to raise_error
    expect(user.avatar).not_to be_attached
  end

  it "follows redirects" do
    stub_request(:get, request_url).to_return(status: 302, headers: { "Location" => "/files/avatar.png" })
    stub_avatar("https://chat.example.com/files/avatar.png")

    described_class.perform_now(user)

    expect(user.avatar).to be_attached
  end

  it "keeps the stored avatar when the image is unchanged" do
    stub_avatar
    described_class.perform_now(user)

    expect { described_class.perform_now(user) }.not_to change { user.reload.avatar.blob.id }
  end

  it "replaces the stored avatar when the image changed" do
    stub_avatar
    described_class.perform_now(user)
    stub_avatar(body: stored_image.flip(:horizontal).pngsave_buffer)

    expect { described_class.perform_now(user) }.to change { user.reload.avatar.blob.id }
  end

  context "when the Rocket.Chat API is configured" do
    let(:cookie) { "rc_uid=my-id; rc_token=my-token" }

    before do
      config = RocketChatApiConfig.new(host: "https://chat.example.com", user_id: "my-id", auth_token: "my-token")
      allow(RocketChatApiConfig).to receive(:instance).and_return(config)
    end

    it "authenticates the download from the workspace, e.g. when avatars are protected" do
      stub_request(:get, request_url).with(headers: { "Cookie" => cookie })
                                     .to_return(status: 200, body: png, headers: { "Content-Type" => "image/png" })

      described_class.perform_now(user)

      expect(user.avatar).to be_attached
    end

    it "doesn't send the credentials to other hosts" do
      other_url = "https://files.example.com/avatar.png"
      stub_request(:get, request_url).to_return(status: 302, headers: { "Location" => other_url })
      stub_avatar(other_url)

      described_class.perform_now(user)

      expect(a_request(:get, request_url).with(headers: { "Cookie" => cookie })).to have_been_made
      expect(a_request(:get, other_url).with { |request| request.headers.key?("Cookie") }).not_to have_been_made
      expect(user.avatar).to be_attached
    end
  end

  it "doesn't send credentials when the Rocket.Chat API isn't configured" do
    stub_avatar

    described_class.perform_now(user)

    expect(a_request(:get, request_url).with { |request| request.headers.key?("Cookie") }).not_to have_been_made
  end

  it "skips avatars that don't exist" do
    stub_avatar(status: 404, body: "")

    described_class.perform_now(user)

    expect(user.avatar).not_to be_attached
  end

  it "skips avatars larger than the maximum size" do
    stub_const("#{described_class}::MAX_DOWNLOAD_SIZE", png.bytesize - 1)
    stub_avatar

    described_class.perform_now(user)

    expect(user.avatar).not_to be_attached
  end

  it "discards responses that aren't images" do
    stub_avatar(body: "<html></html>", headers: { "Content-Type" => "text/html" })

    expect { described_class.perform_now(user) }.not_to raise_error
    expect(user.avatar).not_to be_attached
  end

  it "retries on server errors" do
    stub_avatar(status: 503, body: "")

    expect { described_class.perform_now(user) }.to have_enqueued_job(described_class).with(user)
  end

  it "retries on too many redirects" do
    stub_request(:get, request_url).to_return(status: 302, headers: { "Location" => request_url })

    expect { described_class.perform_now(user) }.to have_enqueued_job(described_class).with(user)
  end

  [ "", "/seeds/avatars/john.smith.jpg", "file:///etc/passwd", "ftp://example.com/avatar.png" ].each do |url|
    it "skips the avatar URL #{url.inspect}" do
      user.update_column(:avatar_url, url)

      described_class.perform_now(user)

      expect(user.avatar).not_to be_attached
    end
  end
end
