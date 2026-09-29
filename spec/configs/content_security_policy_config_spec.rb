# frozen_string_literal: true

require "rails_helper"

describe ContentSecurityPolicyConfig, type: :config do
  subject { described_class.new }
  let(:csp_config) { Rails.application.config.content_security_policy }

  context "by default" do
    it "is enabled" do
      expect(subject.disabled).to eq(false)
      expect(csp_config.class).to eq(ActionDispatch::ContentSecurityPolicy)
    end

    it "is enforced" do
      expect(subject.report_only).to eq(false)
      expect(Rails.application.config.content_security_policy_report_only).to eq(false)
    end

    it "doesn't report violations" do
      expect(subject.report_uri).to be_nil
      expect(csp_config.directives).not_to include(:report_uri)
    end

    it "uses the base policy" do
      expect(subject.default_src).to be_nil
      expect(subject.script_src).to be_nil
      expect(subject.connect_src).to be_nil
      expect(subject.frame_src).to be_nil
      expect(subject.style_src).to be_nil
      expect(subject.img_src).to be_nil
      expect(subject.font_src).to be_nil
      expect(subject.media_src).to be_nil
      expect(subject.worker_src).to be_nil
      expect(subject.form_action).to be_nil
      expect(subject.frame_ancestors).to be_nil
    end
  end

  describe "#sources" do
    context "when the directive's value is nil" do
      it "returns an empty array" do
        config = described_class.new
        expect(config.sources(:default_src)).to eq([])
      end
    end

    context "when the directive's value is an Array" do
      it "returns the array" do
        config = described_class.new
        config.default_src = [ "https://one.example.com", "https://two.example.com" ]
        expect(config.sources(:default_src)).to eq([ "https://one.example.com", "https://two.example.com" ])
      end
    end

    context "when the directive's value is a String" do
      it "returns the string" do
        config = described_class.new
        config.default_src = "https://one.example.com"
        expect(config.sources(:default_src)).to eq("https://one.example.com")
      end
    end

    context "otherwise" do
      it "returns an empty array" do
        config = described_class.new
        config.default_src = true
        expect(config.sources(:default_src)).to eq([])
      end
    end
  end

  describe "#report_uri?" do
    it "returns true when report_uri is present and not empty" do
      config = described_class.new
      config.report_uri = "https://example.com/csp-report"
      expect(config.report_uri?).to be(true)
    end

    it "returns false when report_uri is nil" do
      config = described_class.new
      config.report_uri = nil
      expect(config.report_uri?).to be(false)
    end

    it "returns false when report_uri is empty" do
      config = described_class.new
      config.report_uri = ""
      expect(config.report_uri?).to be(false)
    end
  end

  describe "#validated_report_uri" do
    it "returns the report_uri if it is a valid https URL" do
      config = described_class.new
      config.report_uri = "https://example.com/csp-report"
      expect(config.validated_report_uri).to eq("https://example.com/csp-report")
    end

    it "returns the report_uri if it is an same-origin path" do
      config = described_class.new
      config.report_uri = "/csp-report"
      expect(config.validated_report_uri).to eq("/csp-report")
    end

    it "raises an error if the report_uri is invalid" do
      config = described_class.new
      config.report_uri = "not-a-url"
      expect { config.validated_report_uri }.to raise_error(ArgumentError)
    end
  end

  describe "future regressions" do
    context "the `report_uri` directive is deprecated" do
      context "when Rails supports `report_to` in the future" do
        it "offers a `report_to` option" do
          # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/report-uri
          if Rails.application.config.content_security_policy.respond_to?(:report_to)
            expect(subject).to respond_to(:report_to)
          end
        end
      end
    end
  end
end
