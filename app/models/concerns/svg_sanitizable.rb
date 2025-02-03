# frozen_string_literal: true

module SvgSanitizable
  extend ActiveSupport::Concern

  def sanitize_svg(uploaded_file)
    return uploaded_file unless svg?(uploaded_file)

    sanitized_content = Gitlab::Sanitizers::Svg.clean(uploaded_file.read)
    {
      io: StringIO.new(sanitized_content),
      filename: uploaded_file.original_filename,
      content_type: uploaded_file.content_type
    }
  end

  private

  def svg?(uploaded_file)
    return false unless uploaded_file.is_a?(ActionDispatch::Http::UploadedFile)
    uploaded_file.content_type == "image/svg+xml" ||
      File.extname(uploaded_file.original_filename).casecmp(".svg").zero?
  end
end
