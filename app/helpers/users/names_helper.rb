module Users::NamesHelper
  # Extracts and formats the first name from a username.
  #
  # The method assumes the username is in the format of 'first_name.last_name' or 'first-names.last-names'.
  # It splits the username by periods and hyphens, capitalizes each part of the first name, and joins
  # them with a space to handle cases like 'john-jack.doe' where 'John Jack' should be the first name.
  #
  # @param [String] username The username in the format of 'first.last' or 'first-names.last-names'.
  # @return [String] The capitalized and formatted first name(s) extracted from the username.
  #
  # @example
  #   first_name('john-jack.doe') # => "John Jack"
  #
  #   first_name('jane.doe')       # => "Jane"
  #
  def extract_first_name(user)
    first_names = user.username.split(".").first.split("-")

    first_name_hyphenated = first_names.map(&:capitalize).join("-")
    return first_name_hyphenated if user.name.starts_with?(first_name_hyphenated)

    first_names.map(&:capitalize).join(" ")
  end
end
