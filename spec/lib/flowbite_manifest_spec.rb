require "rails_helper"

# Upgrading Flowbite has to re-import its examples, see bin/flowbite-inventory
# in gems/gustwave.
RSpec.describe "The Flowbite manifest" do
  it "matches the installed Flowbite version" do
    manifest = YAML.safe_load(Gustwave::Engine.root.join("lookbook/flowbite.yml").read(encoding: "utf-8"))
    lockfile = JSON.parse(Rails.root.join("package-lock.json").read)

    expect(manifest["flowbite_version"]).to eq(lockfile.dig("packages", "node_modules/flowbite", "version"))
  end
end
