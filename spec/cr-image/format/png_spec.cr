require "../../spec_helper"

Spectator.describe CrImage::Format::PNG do
  include SpecHelper

  describe ".from_png and #to_png" do
    it "works with GrayscaleImage" do
      with_sample("scenic/moon.png") do |io|
        image = CrImage::GrayscaleImage.from_png(io)
        io = IO::Memory.new
        image.to_png(io)

        expect_digest(io.to_s).to eq "8635306d7a0201533e8812ebf3671b9c2e31c4b0"
      end
    end

    it "works with RGBAImage" do
      with_sample("scenic/moon.png") do |io|
        image = CrImage::RGBAImage.from_png(io)
        io = IO::Memory.new
        image.to_png(io)

        expect_digest(io.to_s).to eq "4623c3074b418ca58a9c083297baa3fefaad8f1c"
      end
    end
  end
end
