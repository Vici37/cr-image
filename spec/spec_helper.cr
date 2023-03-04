require "digest"
require "spectator"
require "spectator/should"
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

  macro specs_for_operator(op, gray_hash, rgba_hash)
    describe CrImage::GrayscaleImage do
      it {{"##{op.id}"}} do
        expect_digest(gray_moon_ppm.{{op}}).to eq {{gray_hash}}
      end
    end

    describe CrImage::RGBAImage do
      it {{"##{op.id}"}} do
        expect_digest(rgba_moon_ppm.{{op}}).to eq {{rgba_hash}}
      end
    end
  end

  def with_sample(filename : String, &)
    File.open("lib/cr-image-samples/#{filename}") do |file|
      yield file
    end
  end

  def self.bit_arr(size : Int32, int : Int)
    BitArray.new(size) { |i| int.bit(size - i - 1) > 0 }
  end
end
