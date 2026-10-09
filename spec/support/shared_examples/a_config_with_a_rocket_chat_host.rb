# Rocket.Chat configs should return the workspace host as a URL, whether it
# was configured with or without a scheme.
RSpec.shared_examples "a config with a Rocket.Chat host" do
  subject(:config) { described_class.new }

  it "adds https to a host without a scheme" do
    config.host = "chat.example.com"
    expect(config.host).to eq("https://chat.example.com")
  end

  it "keeps an http scheme" do
    config.host = "http://chat.example.com"
    expect(config.host).to eq("http://chat.example.com")
  end

  it "keeps an https scheme" do
    config.host = "HTTPS://chat.example.com"
    expect(config.host).to eq("HTTPS://chat.example.com")
  end

  it "removes a trailing slash" do
    config.host = "https://chat.example.com/"
    expect(config.host).to eq("https://chat.example.com")
  end

  it "keeps a blank host blank" do
    config.host = ""
    expect(config.host).to eq("")
  end
end
