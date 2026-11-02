# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require_relative "../../script/flowbite_examples"

RSpec.describe Gustwave::FlowbiteExamples do
  describe ".parse" do
    it "reads the id, classes and html of each example" do
      markdown = <<~MD
        ## Basic

        {{< example id="first" class="mt-4 flex" >}}
        <button>One</button>
        {{< /example >}}

        {{< example id="second" bodyClass="bg-gray-50" class="p-2" >}}
        <p>Two</p>
        {{< /example >}}
      MD

      examples = described_class.parse(markdown)

      expect(examples.map(&:id)).to eq(%w[first second])
      expect(examples.first).to have_attributes(
        html: "<button>One</button>\n", wrapper_class: "mt-4 flex", body_class: "", init_js: true
      )
      expect(examples.last).to have_attributes(
        html: "<p>Two</p>\n", wrapper_class: "p-2", body_class: "bg-gray-50", init_js: true
      )
    end

    it "does not mistake bodyClass for class" do
      markdown = %({{< example id="a" bodyClass="bg-red-500" >}}\n<i></i>\n{{< /example >}}\n)

      expect(described_class.parse(markdown).first).to have_attributes(wrapper_class: "", body_class: "bg-red-500")
    end

    it "falls back to a zero-based index for an example without an id" do
      markdown = "{{< example class=\"a\" >}}\n1\n{{< /example >}}\n{{< example >}}\n2\n{{< /example >}}\n"

      expect(described_class.parse(markdown).map(&:id)).to eq([ "example-0", "example-1" ])
    end

    it "reads attributes spread over several lines" do
      markdown = <<~MD
        {{< example id="wide"
          class="w-full"
          bodyClass="dark:bg-gray-800" >}}
        <div></div>
        {{< /example >}}
      MD

      expect(described_class.parse(markdown).first).to have_attributes(
        id: "wide", wrapper_class: "w-full", body_class: "dark:bg-gray-800"
      )
    end

    it "turns off init_js for disable_init_js=true, bare or quoted" do
      markdown = <<~MD
        {{< example id="off" disable_init_js=true >}}
        {{< /example >}}
        {{< example id="quoted" disable_init_js="true" >}}
        {{< /example >}}
        {{< example id="on" >}}
        {{< /example >}}
      MD

      expect(described_class.parse(markdown).map(&:init_js)).to eq([ false, false, true ])
    end
  end

  describe ".page_html" do
    let(:example) do
      Gustwave::FlowbiteExamples::Example.new(
        id: "demo", html: "<button data-dropdown-toggle=\"x\">Open</button>", wrapper_class: "mt-4",
        body_class: "bg-gray-50", init_js: true
      )
    end

    it "wraps the html with the body and wrapper classes" do
      html = described_class.page_html(example)

      expect(html).to include('<body class="p-5 bg-white dark:bg-gray-900 antialiased bg-gray-50">')
      expect(html).to include('<div id="exampleWrapper" class="mt-4">')
      expect(html).to include(example.html)
    end

    it "opens the first overlays when init_js is on" do
      expect(described_class.page_html(example)).to include("dropdownEl.click()")
    end

    it "does not open the overlays when init_js is off" do
      example.init_js = false

      html = described_class.page_html(example)

      expect(html).not_to include("dropdownEl.click()")
      expect(html).to include("preventDefault")
    end

    it "always prevents link navigation" do
      example.init_js = false

      expect(described_class.page_html(example)).to include("preventDefault")
    end

    it "escapes quotes in the wrapper class" do
      example.wrapper_class = 'a" onmouseover="alert(1)'

      expect(described_class.page_html(example)).to include('class="a&quot; onmouseover=&quot;alert(1)"')
    end
  end

  describe ".write_pages" do
    it "writes one file per example and returns the count" do
      markdown = "{{< example id=\"one\" >}}\n1\n{{< /example >}}\n{{< example >}}\n2\n{{< /example >}}\n"

      Dir.mktmpdir do |dir|
        expect(described_class.write_pages(markdown, dir)).to eq(2)
        expect(Dir.children(File.join(dir, "examples")).sort).to eq([ "example-1.html", "one.html" ])
        expect(File.read(File.join(dir, "examples", "one.html"))).to include("<html lang=\"en\">")
      end
    end
  end
end
