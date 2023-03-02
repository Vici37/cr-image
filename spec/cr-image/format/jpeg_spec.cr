require "../../spec_helper"

Spectator.describe CrImage::Format::JPEG do
  include SpecHelper

  describe ".from_jpeg" do
    it "works with RGBAImage" do
      data = SpecHelper.read_sample("moon.jpg")
      image = CrImage::RGBAImage.from_jpeg(data)

      expect_digest(image.to_jpeg).to eq "9e64f8649d150a89c55e6741ba265a416e04ff64"
    end

    it "works with GrayscaleImage" do
      data = SpecHelper.read_sample("moon.jpg")
      image = CrImage::GrayscaleImage.from_jpeg(data)

      expect_digest(image.to_jpeg).to eq "2852f4416025ef0d5856460258bdc47b37883dd6"
    end
  end

  describe "#to_jpeg" do
    it "works with RGBAImage" do
      data = SpecHelper.read_sample("moon.jpg")
      image = CrImage::RGBAImage.from_jpeg(data)

      expect_digest(image.to_jpeg).to eq "9e64f8649d150a89c55e6741ba265a416e04ff64"
    end

    it "works with GrayscaleImage" do
      data = SpecHelper.read_sample("moon.jpg")
      image = CrImage::GrayscaleImage.from_jpeg(data)

      expect_digest(image.to_jpeg).to eq "2852f4416025ef0d5856460258bdc47b37883dd6"
    end
  end
end
