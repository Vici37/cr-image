require "../../spec_helper"

Spectator.describe CrImage::Format::JPEG do
  include SpecHelper

  describe ".from_jpeg and #to_jpeg" do
    it "works with RGBAImage" do
      with_sample("scenic/moon.jpg") do |file|
        image = CrImage::RGBAImage.from_jpeg(file)

        io = IO::Memory.new
        image.to_jpeg(io)
        expect_digest(io.to_s).to eq "9e64f8649d150a89c55e6741ba265a416e04ff64"
      end
    end

    it "works with GrayscaleImage" do
      with_sample("scenic/moon.jpg") do |file|
        image = CrImage::GrayscaleImage.from_jpeg(file)

        io = IO::Memory.new
        image.to_jpeg(io)
        expect_digest(io.to_s).to eq "2852f4416025ef0d5856460258bdc47b37883dd6"
      end
    end
  end
end
