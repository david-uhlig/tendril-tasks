require 'rails_helper'

RSpec.describe Users::NamesHelper, type: :helper do
  describe "#extract_greetings_name" do
    it "returns capitalized first name for regular names" do
      user = build(:user, name: "John Doe", username: "john.doe")
      first_name = extract_first_name(user)
      expect(first_name).to eq("John")
    end

    it "returns capitalized first name for two last names" do
      user = build(:user, name: "Jane Doe-Poe", username: "jane.doe-poe")
      first_name = extract_first_name(user)
      expect(first_name).to eq("Jane")
    end

    it "returns all capitalized first names for two first names" do
      user = build(:user, name: "John Max Doe", username: "john-max.doe")
      first_name = extract_first_name(user)
      expect(first_name).to eq("John Max")
    end

    it "returns the first names hyphenated if the hyphen is present in the real name" do
      user = build(:user, name: "John-Max Doe", username: "john-max.doe")
      first_name = extract_first_name(user)
      expect(first_name).to eq("John-Max")
    end
  end
end
