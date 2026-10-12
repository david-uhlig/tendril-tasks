# frozen_string_literal: true

module Release
  # Reads and writes `TendrilTasks::VERSION` in config/version.rb
  class VersionFile
    PATTERN = /VERSION = "([^"]+)"/

    def initialize(path)
      @path = path
    end

    def read = File.read(@path)[PATTERN, 1]

    def write(version)
      File.write(@path, File.read(@path).sub(PATTERN, %(VERSION = "#{version}")))
    end
  end
end
