# frozen_string_literal: true

# Docstrings for Gustwave::ComponentStatus to read, see
# spec/lookbook/component_status_spec.rb.
module ComponentStatusFixtures
  # No status
  class Untagged; end

  # A docstring, then a status.
  #
  # @status beta
  class Beta; end

  # @status alpha
  # @status beta
  class Twice; end

  # @status experimental
  class Unknown; end

  # @status
  class Empty; end

  # @status stable

  # A blank line separates the tag above from this docstring.
  class Detached; end
end
