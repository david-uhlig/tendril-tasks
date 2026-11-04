require "rails_helper"
require_relative "../../lookbook/component_status"

# Every component states its status with exactly one @status tag in its class
# docstring, and a deprecated one warns at runtime. See "Component lifecycle"
# in docs/design.md.
RSpec.describe "Component statuses" do
  statuses = Gustwave::ComponentStatus
  rule = "docs/design.md#component-lifecycle"

  statuses.components.each do |component|
    it "#{component.name} has exactly one valid @status tag" do
      tags = statuses.tags(component)

      expect(tags.size).to eq(1),
        "#{component.name} needs exactly one `# @status <status>` line directly above its class, found #{tags.size}. See #{rule}"
      expect(statuses::STATUSES).to include(tags.first),
        "#{component.name} has `@status #{tags.first}`; use one of #{statuses::STATUSES.join(", ")}. See #{rule}"
    end

    next unless statuses.for(component) == "deprecated"

    it "#{component.name} warns that it's deprecated" do
      file, = Object.const_source_location(component.name)

      expect(File.read(file)).to include("Gustwave.deprecator.warn"),
        "#{component.name} is deprecated, so its constructor warns through Gustwave.deprecator. See #{rule}"
    end
  end
end
