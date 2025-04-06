# Docker images and other CI releases must bake in the commit
commit_file = Rails.root.join("COMMIT_HASH")

GIT_COMMIT =
  if commit_file.exist?
    commit_file.read.strip
  else
    `git rev-parse --short HEAD`.chomp rescue "unknown"
  end.freeze
