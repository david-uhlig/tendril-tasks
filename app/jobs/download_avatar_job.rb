# frozen_string_literal: true

# Downloads the user's avatar from their `avatar_url` and stores it as the
# user's `avatar`, so browsers load avatars from this app instead of the
# Rocket.Chat workspace.
#
# The image is cropped to a square, scaled down and converted to WebP without
# metadata. An unchanged image is not stored again. SVG images are skipped,
# because Active Storage blocks loading them for security, so Rocket.Chat is
# asked to render its default letter avatars as PNG.
#
# When Rocket.Chat blocks unauthenticated access to avatars, the personal
# access token of the Rocket.Chat API config authenticates the download. It is
# only sent to the workspace, not to other hosts the download redirects to.
class DownloadAvatarJob < ApplicationJob
  class DownloadError < StandardError; end

  # Twice the largest avatar size for high density screens.
  SIZE = 288
  MAX_DOWNLOAD_SIZE = 5.megabytes
  MAX_REDIRECTS = 3
  TIMEOUT = 10.seconds

  discard_on ActiveJob::DeserializationError
  # Not an image, or one that can't be read, e.g. SVG.
  discard_on Vips::Error
  retry_on DownloadError, Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError,
           wait: :polynomially_longer, attempts: 5

  def perform(user)
    uri = http_uri(user.avatar_url)
    # E.g. blank, or a path to a local file in development.
    return if uri.nil?

    body = download(with_rocket_chat_params(uri))
    return if body.nil?

    checksum = Digest::SHA256.base64digest(body)
    return if user.avatar.attached? && user.avatar.metadata["source_checksum"] == checksum

    image = ImageProcessing::Vips.source(Vips::Image.new_from_buffer(body, ""))
                                 .resize_to_fill(SIZE, SIZE)
                                 .convert("webp")
                                 .saver(strip: true)
                                 .call
    user.avatar.attach(io: image,
                       filename: "avatar.webp",
                       content_type: "image/webp",
                       metadata: { source_checksum: checksum })
  end

  private

  def http_uri(url)
    uri = URI.parse(url.to_s)
    uri if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end

  # Asks Rocket.Chat to render letter avatars as PNG in the stored size. Other
  # servers ignore the params.
  def with_rocket_chat_params(uri)
    uri.dup.tap do |result|
      params = URI.decode_www_form(uri.query.to_s).to_h.merge("format" => "png", "size" => SIZE.to_s)
      result.query = URI.encode_www_form(params)
    end
  end

  # Returns the response body of a successful request. Follows redirects, e.g.
  # to the storage of the Rocket.Chat workspace. Returns nil when the avatar
  # doesn't exist, access is denied or it is too large.
  def download(uri, redirects: MAX_REDIRECTS)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == "https",
                    open_timeout: TIMEOUT,
                    read_timeout: TIMEOUT) do |http|
      http.request(get_request(uri)) do |response|
        case response
        when Net::HTTPSuccess
          return read_body(response)
        when Net::HTTPRedirection
          raise DownloadError, "Too many redirects downloading #{uri}" if redirects.zero?

          location = http_uri(URI.join(uri, response["location"].to_s).to_s)
          raise DownloadError, "Invalid redirect downloading #{uri}" if location.nil?

          return download(location, redirects: redirects - 1)
        when Net::HTTPServerError, Net::HTTPTooManyRequests
          raise DownloadError, "#{response.code} downloading #{uri}"
        else
          logger.info "Skipped avatar from #{uri}: #{response.code}"
          return
        end
      end
    end
  end

  def get_request(uri)
    Net::HTTP::Get.new(uri).tap do |request|
      request["Cookie"] = RocketChatApiConfig.auth_cookie if RocketChatApiConfig.workspace?(uri)
    end
  end

  def read_body(response)
    body = String.new(encoding: Encoding::BINARY)
    response.read_body do |chunk|
      body << chunk
      if body.bytesize > MAX_DOWNLOAD_SIZE
        logger.info "Skipped avatar from #{response.uri}: larger than #{MAX_DOWNLOAD_SIZE} bytes"
        return
      end
    end
    body
  end
end
