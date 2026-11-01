# frozen_string_literal: true

require "fileutils"
require "open3"
require "securerandom"
require "vips"

RSpec.describe "bin/visual-diff" do
  let(:script) { File.expand_path("../../bin/visual-diff", __dir__) }
  let(:root) { File.expand_path("../../tmp/visual", __dir__) }
  let(:before_label) { "spec-#{SecureRandom.hex(4)}-before" }
  let(:after_label) { "spec-#{SecureRandom.hex(4)}-after" }
  let(:report_dir) { File.join(root, "diff--#{before_label}--#{after_label}") }

  before do
    FileUtils.mkdir_p(File.join(root, before_label))
    FileUtils.mkdir_p(File.join(root, after_label))
  end

  after do
    FileUtils.rm_rf([ File.join(root, before_label), File.join(root, after_label), report_dir ])
  end

  def solid(width, height, colour)
    (Vips::Image.black(width, height, bands: 3) + colour).cast(:uchar)
  end

  def write_png(label, image, name: "page.png")
    image.write_to_file(File.join(root, label, name))
  end

  def run_script(*args)
    output, status = Open3.capture2e(script, before_label, after_label, *args)
    [ output.force_encoding(Encoding::UTF_8), status ]
  end

  def pixel(path, x, y)
    Vips::Image.new_from_file(path).getpoint(x, y).map(&:to_i)
  end

  it "reports identical images as unchanged" do
    write_png(before_label, solid(20, 10, [ 10, 20, 30 ]))
    write_png(after_label, solid(20, 10, [ 10, 20, 30 ]))

    output, status = run_script

    expect(status).to be_success
    expect(output).to include("0 changed, 1 unchanged")
    expect(File.read(File.join(report_dir, "index.html"))).to include("<li>page.png</li>")
  end

  it "counts the changed pixels and highlights them in red" do
    write_png(before_label, solid(20, 10, [ 255, 255, 255 ]))
    write_png(after_label, solid(20, 10, [ 255, 255, 255 ]).insert(solid(3, 2, [ 0, 0, 0 ]), 4, 5))

    output, status = run_script

    expect(status).to be_success
    expect(output).to match(/page\.png\s+6 px/)
    expect(output).to include("1 changed, 0 unchanged")
    diff = File.join(report_dir, "diff--page.png")
    expect(pixel(diff, 4, 5)).to eq([ 255, 0, 0 ])
    expect(pixel(diff, 0, 0)).not_to eq([ 255, 0, 0 ])
  end

  it "ignores colour differences within the fuzz" do
    write_png(before_label, solid(20, 10, [ 100, 100, 100 ]))
    write_png(after_label, solid(20, 10, [ 102, 100, 100 ]))

    output, status = run_script("--fuzz=1%")

    expect(status).to be_success
    expect(output).to include("0 changed, 1 unchanged")
  end

  it "averages the difference across the colour bands" do
    write_png(before_label, solid(20, 10, [ 100, 100, 100 ]))
    write_png(after_label, solid(20, 10, [ 103, 100, 100 ]))

    output, status = run_script("--fuzz=1%")

    expect(status).to be_success
    expect(output).to include("0 changed, 1 unchanged")
  end

  it "counts a pixel as changed when the averaged difference exceeds the fuzz" do
    write_png(before_label, solid(20, 10, [ 100, 100, 100 ]))
    write_png(after_label, solid(20, 10, [ 105, 100, 100 ]))

    output, status = run_script("--fuzz=1%")

    expect(status).to be_success
    expect(output).to match(/page\.png\s+200 px/)
  end

  it "counts any difference with a fuzz of zero" do
    write_png(before_label, solid(20, 10, [ 100, 100, 100 ]))
    write_png(after_label, solid(20, 10, [ 101, 100, 100 ]))

    output, status = run_script("--fuzz=0%")

    expect(status).to be_success
    expect(output).to match(/page\.png\s+200 px/)
  end

  it "pads images of different sizes and reports the size change" do
    write_png(before_label, solid(20, 10, [ 10, 20, 30 ]))
    write_png(after_label, solid(20, 15, [ 10, 20, 30 ]))

    output, status = run_script

    expect(status).to be_success
    expect(output).to match(/page\.png\s+100 px 20x10 → 20x15/)
    expect(pixel(File.join(report_dir, "before--page.png"), 0, 14)).to eq([ 255, 0, 255 ])
  end

  it "compares transparent images on a white background" do
    transparent = solid(20, 10, [ 0, 0, 0 ]).bandjoin(0)
    write_png(before_label, transparent)
    write_png(after_label, solid(20, 10, [ 255, 255, 255 ]))

    output, status = run_script

    expect(status).to be_success
    expect(output).to include("0 changed, 1 unchanged")
  end

  it "lists screenshots that exist on one side only" do
    write_png(before_label, solid(20, 10, [ 10, 20, 30 ]), name: "gone.png")
    write_png(after_label, solid(20, 10, [ 10, 20, 30 ]), name: "new.png")

    output, status = run_script

    expect(status).to be_success
    expect(output).to match(/gone\.png\s+missing_after/)
    expect(output).to match(/new\.png\s+missing_before/)
  end

  it "fails on an unreadable image instead of reporting it as unchanged" do
    write_png(before_label, solid(20, 10, [ 10, 20, 30 ]))
    File.write(File.join(root, after_label, "page.png"), "not a png")

    output, status = run_script

    expect(status).not_to be_success
    expect(output).not_to include("unchanged")
  end

  it "rejects a fuzz that is not a percentage" do
    output, status = run_script("--fuzz=5")

    expect(status).not_to be_success
    expect(output).to include("--fuzz")
  end
end
