require "rails_helper"

# Compares each component's public and extension API to the fixture in
# spec/fixtures/api_snapshots, so every API change shows up in review as a
# fixture diff, next to the status that says whether it needs a deprecation.
# See "Public API and stability" and "Component lifecycle" in docs/design.md.
#
# Run with UPDATE_API_SNAPSHOTS=1 to write the fixtures instead of comparing.
RSpec.describe "API snapshots" do
  dir = Pathname(__dir__).join("../fixtures/api_snapshots").expand_path
  components = Gustwave::ComponentStatus.components
  fixture = ->(component) { dir.join("#{component.name.underscore}.yml") }
  record = "If that's intended, record it with UPDATE_API_SNAPSHOTS=1."
  lifecycle = "See docs/design.md#component-lifecycle."
  changed = ->(component) {
    status = Gustwave::ComponentStatus.for(component)
    case status
    when "beta", "stable"
      "#{component.name}'s API changed, and it's #{status}. Adding is fine, but removing or renaming anything " \
        "needs a deprecation one minor release first (D1). #{record} #{lifecycle}"
    when "deprecated"
      "#{component.name}'s API changed, but it's deprecated: leave its API alone until it's removed in the next " \
        "minor release. #{lifecycle}"
    else
      "#{component.name}'s API changed, and it's #{status || "alpha"}. #{record} A removal or rename needs an " \
        "upgrade note under Breaking Changes in the changelog. #{lifecycle}"
    end
  }

  components.each do |component|
    it "matches for #{component.name}" do
      path = fixture.(component)
      actual = ApiSnapshot.for(component)

      if ENV["UPDATE_API_SNAPSHOTS"]
        path.dirname.mkpath
        path.write(actual.to_yaml(line_width: -1))
      else
        expect(path).to exist,
          "#{component.name} has no API snapshot. Run with UPDATE_API_SNAPSHOTS=1 to write #{path.relative_path_from(dir)}"
        expect(actual).to eq(YAML.load_file(path)), changed.(component)
      end
    end
  end

  it "has no snapshot for a component that no longer exists" do
    expected = components.map { |component| fixture.(component).to_s }
    orphans = Dir.glob(dir.join("**/*.yml").to_s) - expected

    expect(orphans).to be_empty, "Delete the snapshots of removed components: #{orphans.join(", ")}"
  end
end
