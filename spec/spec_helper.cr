require "digest"
require "spectator"
require "../src/cr-image"
require "./helpers/**"

module SpecHelper
  macro included
    include CrImageSampleHelper
  end

  def digest(image : CrImage::Image)
    io = IO::Memory.new
    image.to_ppm(io)
    Digest::SHA1.hexdigest(io.to_s)
  end

  def digest(data : String)
    Digest::SHA1.hexdigest(data)
  end

  macro expect_digest(image)
    expect(digest({{image}}))
  end

  macro specs_for_operator(op, gray_hash, rgba_hash, *, focus = nil)
    describe CrImage::GrayscaleImage{% if focus %}, :focus{% end %} do
      let(image) { gray_moon_ppm }
      it {{"##{op.id}"}} do
        expect_digest(image.{{op}}).to eq {{gray_hash}}
      end
    end

    describe CrImage::RGBAImage{% if focus %}, :focus{% end %} do
      let(image) { rgba_moon_ppm }
      it {{"##{op.id}"}} do
        expect_digest(image.{{op}}).to eq {{rgba_hash}}
      end
    end
  end

  def with_sample(filename : String, &)
    File.open("lib/cr-image-samples/#{filename}") do |file|
      yield file
    end
  end
end
