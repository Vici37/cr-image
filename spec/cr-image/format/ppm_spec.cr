require "../../spec_helper"

Spectator.describe CrImage::Format::PPM do
  include SpecHelper

  describe ".from_ppm and #to_ppm" do
    it "works with RGBAImage" do
      with_sample("scenic/moon.ppm") do |file|
        image = CrImage::RGBAImage.from_ppm(file)

        io = IO::Memory.new
        image.to_ppm(io)
        expect_digest(io.to_s).to eq "d764459f778b4839972367f78197bf9a96cd11fd"
      end
    end

    it "works with GrayscaleImage" do
      with_sample("scenic/moon.ppm") do |file|
        image = CrImage::GrayscaleImage.from_ppm(file)

        io = IO::Memory.new
        image.to_ppm(io)
        expect_digest(io.to_s).to eq "62d6101d60ee8da38d1b9d8e809091099cec5994"
      end
    end
  end
end
