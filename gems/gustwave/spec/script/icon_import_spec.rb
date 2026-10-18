# frozen_string_literal: true

require "fileutils"
require "spec_helper"
require "stringio"
require "tmpdir"
require_relative "../../script/icon_import"

RSpec.describe Gustwave::IconImport do
  let(:source) { described_class.parse_source(described_class::DEFAULT_SOURCE) }
  let(:index) { { [ "outline", "chalkboard-user" ] => "src/outline/education/chalkboard-user.svg" } }

  # Upstream icons whose shape differs from the usual stroke-width="2" outline.
  let(:fill_only_outline) do
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
        <path fill="currentColor" fill-rule="evenodd" d="M6 2h12v20H6V2Z" clip-rule="evenodd"/>
      </svg>
    SVG
  end

  let(:thick_outline) { upstream_outline.sub('stroke-width="2"', 'stroke-width="3"') }

  let(:stroke_solid) do
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" d="M5 12h14M12 5v14"/>
      </svg>
    SVG
  end

  let(:upstream_outline) do
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.7141 15h4.268c.4043 0 .732-.3838.732-.8571V3.85714c0-.47338-.3277-.85714-.732-.85714H6.71411c-.55228 0-1 .44772-1 1v4m10.99999 7v-3h3v3h-3Zm-3 6H6.71411c-.55228 0-1-.4477-1-1 0-1.6569 1.34315-3 3-3h2.99999c1.6569 0 3 1.3431 3 3 0 .5523-.4477 1-1 1Zm-1-9.5c0 1.3807-1.1193 2.5-2.5 2.5s-2.49999-1.1193-2.49999-2.5S8.8334 9 10.2141 9s2.5 1.1193 2.5 2.5Z"/>
      </svg>
    SVG
  end

  let(:converted_outline) do
    <<~SVG
      <svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M14.7141 15h4.268c.4043 0 .732-.3838.732-.8571V3.85714c0-.47338-.3277-.85714-.732-.85714H6.71411c-.55228 0-1 .44772-1 1v4m10.99999 7v-3h3v3h-3Zm-3 6H6.71411c-.55228 0-1-.4477-1-1 0-1.6569 1.34315-3 3-3h2.99999c1.6569 0 3 1.3431 3 3 0 .5523-.4477 1-1 1Zm-1-9.5c0 1.3807-1.1193 2.5-2.5 2.5s-2.49999-1.1193-2.49999-2.5S8.8334 9 10.2141 9s2.5 1.1193 2.5 2.5Z"/>
      </svg>
    SVG
  end

  let(:upstream_solid) do
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 24 24">
        <path fill-rule="evenodd" d="M2 12a10 10 0 1 0 20 0 10 10 0 0 0-20 0Z" clip-rule="evenodd"/>
      </svg>
    SVG
  end

  describe ".convert" do
    it "converts an outline icon exactly" do
      expect(described_class.convert(upstream_outline, theme: "outline")).to eq(converted_outline)
    end

    it "converts every path of a multi-path outline icon" do
      svg = <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <path stroke="currentColor" stroke-width="2" d="M1 1h2"/>
          <path stroke="currentColor" stroke-width="2" d="M3 3h4"/>
        </svg>
      SVG

      converted = described_class.convert(svg, theme: "outline")

      expect(converted.scan('stroke-width="1.5"').size).to eq(2)
      expect(converted).not_to include('stroke-width="2"')
      expect(converted).to start_with('<svg aria-hidden="true" xmlns=')
    end

    it "only adds aria-hidden to a solid icon" do
      expected = upstream_solid.sub("<svg ", '<svg aria-hidden="true" ')

      expect(described_class.convert(upstream_solid, theme: "solid")).to eq(expected)
    end

    it "ends the file with exactly one trailing newline" do
      converted = described_class.convert(upstream_solid.chomp + "\n\n", theme: "solid")

      expect(converted).to end_with("</svg>\n")
      expect(converted).not_to end_with("\n\n")
    end

    it "is idempotent" do
      once = described_class.convert(upstream_outline, theme: "outline")

      expect(described_class.convert(once, theme: "outline")).to eq(once)
      expect(described_class.convert(upstream_solid, theme: "solid"))
        .to eq(described_class.convert(described_class.convert(upstream_solid, theme: "solid"), theme: "solid"))
    end
  end

  describe ".validate!" do
    it "accepts the upstream outline and solid icons" do
      expect { described_class.validate!(upstream_outline, theme: "outline") }.not_to raise_error
      expect { described_class.validate!(upstream_solid, theme: "solid") }.not_to raise_error
    end

    it "rejects a wrong viewBox" do
      svg = upstream_outline.sub('viewBox="0 0 24 24"', 'viewBox="0 0 20 20"')

      expect { described_class.validate!(svg, theme: "outline") }
        .to raise_error(described_class::Error, /viewBox/)
    end

    it "rejects a non-numeric stroke width" do
      svg = upstream_outline.sub('stroke-width="2"', 'stroke-width="thin"')

      expect { described_class.validate!(svg, theme: "outline") }
        .to raise_error(described_class::Error, /stroke-width thin/)
    end

    it "accepts an outline icon drawn with fill currentColor and no stroke width" do
      expect { described_class.validate!(fill_only_outline, theme: "outline") }.not_to raise_error
    end

    it "rejects an outline icon with neither a stroke width nor fill currentColor" do
      svg = fill_only_outline.sub('fill="currentColor"', 'fill="#000"')

      expect { described_class.validate!(svg, theme: "outline") }
        .to raise_error(described_class::Error, /no stroke-width/)
    end

    it "accepts a stroke width other than 2 or 1.5" do
      expect { described_class.validate!(thick_outline, theme: "outline") }.not_to raise_error
    end

    it "accepts a solid icon drawn with stroke currentColor" do
      expect { described_class.validate!(stroke_solid, theme: "solid") }.not_to raise_error
    end

    it "rejects a solid icon without fill or stroke currentColor" do
      svg = upstream_solid.sub('fill="currentColor"', 'fill="#000"')

      expect { described_class.validate!(svg, theme: "solid") }
        .to raise_error(described_class::Error, /currentColor/)
    end
  end

  describe ".violations" do
    it "is empty for a converted icon" do
      expect(described_class.violations(converted_outline, theme: "outline")).to be_empty
    end

    it "flags a missing aria-hidden" do
      problems = described_class.violations(upstream_outline.sub('stroke-width="2"', 'stroke-width="1.5"'), theme: "outline")

      expect(problems).to contain_exactly(a_string_including("aria-hidden"))
    end

    it "flags stroke-width 2 on an outline icon" do
      problems = described_class.violations(upstream_outline.sub("<svg ", '<svg aria-hidden="true" '), theme: "outline")

      expect(problems).to contain_exactly(a_string_including('stroke-width="2"'))
    end

    it "accepts the outlier shapes once converted" do
      [ fill_only_outline, thick_outline ].each do |svg|
        converted = described_class.convert(svg, theme: "outline")

        expect(described_class.violations(converted, theme: "outline")).to be_empty
      end
      converted = described_class.convert(stroke_solid, theme: "solid")

      expect(described_class.violations(converted, theme: "solid")).to be_empty
    end
  end

  describe ".parse_source" do
    it "splits a GitHub tree URL into owner, repo, ref and root" do
      expect(described_class.parse_source("https://github.com/themesberg/flowbite-icons/tree/main/src"))
        .to eq(owner: "themesberg", repo: "flowbite-icons", ref: "main", root: "src")
    end

    it "accepts a tree URL without a path" do
      expect(described_class.parse_source("https://github.com/acme/icons/tree/v2"))
        .to eq(owner: "acme", repo: "icons", ref: "v2", root: "")
    end

    it "rejects other URLs" do
      expect { described_class.parse_source("https://example.com/icons") }
        .to raise_error(described_class::Error, /unsupported source/)
    end
  end

  describe ".resolve" do
    def resolve(arg, theme: "outline")
      described_class.resolve(arg, theme: theme, index: index, source: source)
    end

    let(:raw_url) do
      "https://raw.githubusercontent.com/themesberg/flowbite-icons/v1.5.0/src/outline/education/chalkboard-user.svg"
    end

    it "resolves a bare name through the index" do
      expect(resolve("chalkboard-user")).to have_attributes(theme: "outline", name: "chalkboard-user", url: raw_url)
    end

    it "uses the --theme for a bare name" do
      index[[ "solid", "chalkboard-user" ]] = "src/solid/education/chalkboard-user.svg"

      expect(resolve("chalkboard-user", theme: "solid").url)
        .to eq("https://raw.githubusercontent.com/themesberg/flowbite-icons/v1.5.0/src/solid/education/chalkboard-user.svg")
    end

    it "resolves a THEME/CATEGORY/NAME path with or without src/ and .svg" do
      [ "outline/education/chalkboard-user", "src/outline/education/chalkboard-user.svg" ].each do |arg|
        expect(resolve(arg)).to have_attributes(theme: "outline", name: "chalkboard-user", url: raw_url)
      end
    end

    it "rewrites a GitHub blob URL to the raw URL" do
      url = "https://github.com/themesberg/flowbite-icons/blob/v1.5.0/src/outline/education/chalkboard-user.svg"

      expect(resolve(url)).to have_attributes(theme: "outline", name: "chalkboard-user", url: raw_url)
    end

    it "raises for a name that is not upstream" do
      expect { resolve("no-such-icon") }.to raise_error(described_class::Error, /no outline icon named no-such-icon/)
    end

    it "raises for a path that is not upstream" do
      expect { resolve("outline/arrows/chalkboard-user") }.to raise_error(described_class::Error, /not found upstream/)
    end
  end

  describe "CLI" do
    let(:icons_dir) { Dir.mktmpdir }
    let(:out) { StringIO.new }
    let(:err) { StringIO.new }
    let(:raw_root) { "https://raw.githubusercontent.com/themesberg/flowbite-icons/v1.5.0" }

    # Upstream index: local outline/chalkboard-user, new outline/calendar-plus and outline/broken,
    # new solid/chalkboard-user and solid/laravel.
    let(:upstream) do
      {
        [ "outline", "chalkboard-user" ] => "src/outline/education/chalkboard-user.svg",
        [ "outline", "calendar-plus" ] => "src/outline/general/calendar-plus.svg",
        [ "outline", "broken" ] => "src/outline/general/broken.svg",
        [ "solid", "chalkboard-user" ] => "src/solid/education/chalkboard-user.svg",
        [ "solid", "laravel" ] => "src/solid/brands/laravel.svg"
      }
    end

    let(:svgs) do
      {
        "#{raw_root}/src/outline/education/chalkboard-user.svg" => upstream_outline,
        "#{raw_root}/src/outline/general/calendar-plus.svg" => fill_only_outline,
        "#{raw_root}/src/outline/general/broken.svg" => fill_only_outline.sub('fill="currentColor"', 'fill="#000"'),
        "#{raw_root}/src/solid/education/chalkboard-user.svg" => upstream_solid,
        "#{raw_root}/src/solid/brands/laravel.svg" => stroke_solid
      }
    end

    before do
      allow(described_class).to receive(:build_index).and_return(upstream)
      allow(described_class).to receive(:http_get) { |uri, *| svgs.fetch(uri.to_s) }
      FileUtils.mkdir_p([ File.join(icons_dir, "outline"), File.join(icons_dir, "solid") ])
      write_local("outline", "chalkboard-user", described_class.convert(upstream_outline, theme: "outline"))
    end

    after { FileUtils.remove_entry(icons_dir) }

    def write_local(theme, name, svg)
      File.write(File.join(icons_dir, theme, "#{name}.svg"), svg)
    end

    def local?(theme, name)
      File.exist?(File.join(icons_dir, theme, "#{name}.svg"))
    end

    def run(args)
      described_class::CLI.new(args, out: out, err: err, icons_dir: icons_dir).run
    end

    describe "--new" do
      it "adds the missing icons of both themes and skips the local ones" do
        expect(run([ "--new", "--only", "*" ])).to eq(1)

        expect(out.string).to include("added solid/chalkboard-user.svg", "added solid/laravel.svg",
                                      "added outline/calendar-plus.svg")
        expect(out.string).not_to include("outline/chalkboard-user.svg")
        expect(out.string).to include("added 3, excluded 0, failed 1")
      end

      it "adds only the missing solid icons with --theme solid" do
        expect(run([ "--new", "--theme", "solid" ])).to eq(0)

        expect(local?("solid", "chalkboard-user")).to be(true)
        expect(local?("solid", "laravel")).to be(true)
        expect(local?("outline", "calendar-plus")).to be(false)
        expect(out.string).to eq(<<~OUT)
          added solid/chalkboard-user.svg
          added solid/laravel.svg
          added 2, excluded 0, failed 0
        OUT
      end

      it "writes the converted SVG" do
        run([ "--new", "--theme", "outline", "--only", "calendar-plus" ])

        expect(File.read(File.join(icons_dir, "outline", "calendar-plus.svg")))
          .to eq(described_class.convert(fill_only_outline, theme: "outline"))
      end

      it "continues after a failure and exits 1" do
        expect(run([ "--new", "--theme", "outline" ])).to eq(1)

        expect(local?("outline", "calendar-plus")).to be(true)
        expect(local?("outline", "broken")).to be(false)
        expect(err.string).to include("failed outline/broken.svg: outline icon has no stroke-width")
        expect(out.string).to include("added 1, excluded 0, failed 1")
      end

      it "writes nothing with --dry-run" do
        expect(run([ "--new", "--dry-run", "--theme", "solid" ])).to eq(0)

        expect(out.string).to eq(<<~OUT)
          would add solid/chalkboard-user.svg
          would add solid/laravel.svg
          added 2, excluded 0, failed 0
        OUT
        expect(Dir.children(File.join(icons_dir, "solid"))).to be_empty
      end

      it "filters by upstream category" do
        expect(run([ "--new", "--category", "brands" ])).to eq(0)

        expect(out.string).to eq("added solid/laravel.svg\nadded 1, excluded 0, failed 0\n")
      end

      it "filters by a name glob" do
        expect(run([ "--new", "--only", "lara*" ])).to eq(0)

        expect(out.string).to eq("added solid/laravel.svg\nadded 1, excluded 0, failed 0\n")
      end

      it "skips excluded icons and reports them" do
        stub_const("Gustwave::IconImport::EXCLUDED", %w[solid/laravel.svg])

        expect(run([ "--new", "--theme", "solid" ])).to eq(0)

        expect(local?("solid", "laravel")).to be(false)
        expect(out.string).to eq(<<~OUT)
          added solid/chalkboard-user.svg
          excluded solid/laravel.svg
          added 1, excluded 1, failed 0
        OUT
      end

      it "rejects combining --new with another mode" do
        expect(run([ "--new", "--check" ])).to eq(1)

        expect(err.string).to include("use only one of --new, --reimport and --check")
      end
    end

    describe "--reimport" do
      it "skips excluded icons and reports them" do
        stub_const("Gustwave::IconImport::EXCLUDED", %w[outline/chalkboard-user.svg])

        expect(run([ "--reimport", "--dry-run" ])).to eq(0)

        expect(out.string).to eq("excluded outline/chalkboard-user.svg\n")
      end
    end

    describe "--check" do
      it "passes on converted outlier icons" do
        write_local("outline", "calendar-plus", described_class.convert(fill_only_outline, theme: "outline"))
        write_local("outline", "thick", described_class.convert(thick_outline, theme: "outline"))
        write_local("solid", "laravel", described_class.convert(stroke_solid, theme: "solid"))

        expect(run([ "--check" ])).to eq(0)
        expect(out.string).to be_empty
      end

      it "flags an outline icon still using stroke-width 2" do
        write_local("outline", "unconverted", upstream_outline.sub("<svg ", '<svg aria-hidden="true" '))

        expect(run([ "--check" ])).to eq(1)
        expect(out.string).to include('outline/unconverted.svg: stroke-width="2"')
      end
    end
  end
end
