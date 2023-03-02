require "digest"
require "spectator"
require "spectator/should"
require "../src/cr-image"
require "./helpers/**"

module SpecHelper
  macro included
    include CrImageSampleHelper
  end

  def digest(image : CrImage::Image | String)
    data = (image.is_a?(CrImage::Image) ? image.to_ppm : image)
    Digest::SHA1.hexdigest(data)
  end

  def expect_digest(image : CrImage::Image | String)
    expect(digest(image))
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

  def self.read_sample(name : String) : String
    File.read("lib/cr-image-samples/scenic/#{name}")
  end

  def self.bit_arr(size : Int32, int : Int)
    BitArray.new(size) { |i| int.bit(size - i - 1) > 0 }
  end
end
