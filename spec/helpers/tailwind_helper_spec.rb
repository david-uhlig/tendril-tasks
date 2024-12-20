require 'rails_helper'

RSpec.describe TailwindHelper, type: :helper do
  it "merges Tailwind CSS classes without style conflicts from a string" do
    classes = "font-medium font-bold"
    expect(helper.class_merge(classes)).to eq("font-bold")
  end

  it "merges Tailwind CSS classes without style conflicts from an array" do
    classes = %w[font-medium font-bold]
    expect(helper.class_merge(classes)).to eq("font-bold")
  end

  it "returns immutable strings" do
    # Prevents accidental modification of the string in the cache of the
    # underlying gem
    classes = %w[font-medium font-bold]
    merged = helper.class_merge(classes)
    expect(merged).to eq("font-bold")
    expect(merged).to be_frozen
  end
end
