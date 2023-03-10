require "../../spec_helper"

Spectator.describe CrImage::Format::PNG do
  include SpecHelper

  describe ".from_png and #to_png" do
    it "works with GrayscaleImage" do
      with_sample("scenic/moon.png") do |io|
        image = CrImage::GrayscaleImage.from_png(io)
        io = IO::Memory.new
        image.to_png(io)

        expect_digest(io.to_s).to eq "5c2b3379730b878e3241220bda6e9734709d06a8"
      end
    end

    it "works with RGBAImage" do
      with_sample("scenic/moon.png") do |io|
        image = CrImage::RGBAImage.from_png(io)
        io = IO::Memory.new
        image.to_png(io)

        expect_digest(io.to_s).to eq "4cac53568704ac1617cd96313658559f22c1a24b"
      end
    end
  end
end
