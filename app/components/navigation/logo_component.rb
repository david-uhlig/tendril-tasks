# frozen_string_literal: true

# Renders a logo with an optional link and label.
#
# This component can display an image logo or fallback to a text label if the image is not provided.
# If no label is provided, a default fallback label is used.
#
# Example usage:
#   = render Navigation::LogoComponent.new(src: "logo.png", alt: "Company Logo", label: "My Company", href: "/")
#   = render Navigation::LogoComponent.new(label: "My Company") do
#     Default Logo
#
# Attributes:
# @src [String, nil] The source URL for the logo image. Optional. If not provided, the logo will not be displayed.
# @alt [String] The alt text for the logo image, which is important for accessibility. Defaults to "Logo".
# @label [String, nil] The text label to be displayed alongside the logo. If not provided, a default label is used.
# @href [String] The URL the logo links to. Defaults to "#".
class Navigation::LogoComponent < ApplicationComponent
  # Fallback label used if no label is provided.
  FALLBACK_LABEL = "Job Portal".freeze

  # Initializes the logo component.
  #
  # @param src [String, nil] The source URL for the logo image. Optional. If not provided, the logo will not be displayed.
  # @param alt [String] The alt text for the logo image, important for accessibility. Defaults to "Logo".
  # @param label [String, nil] The text label to display alongside the logo. If not provided, a default label is used.
  # @param href [String] The URL the logo links to. Defaults to "#".
  def initialize(src: nil, alt: "Logo", label: nil, href: "#")
    @src = src
    @alt = alt
    @label = label
    @href = href || "#"
  end

  private

  # Checks if a logo source is provided.
  #
  # @return [Boolean] Whether the logo source is present.
  def logo_present?
    @src.present?
  end

  # Determines the label to display.
  #
  # The method prioritizes the block content, followed by the `@label`, and lastly falls back to a default label.
  #
  # @return [String] The label to display alongside the logo.
  def application_label
    content || @label || FALLBACK_LABEL
  end
end
