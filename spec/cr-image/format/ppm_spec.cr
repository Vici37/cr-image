require "../../spec_helper"

Spectator.describe CrImage::Format::PPM do
  include SpecHelper

  describe ".from_ppm" do
    it "works with RGBAImage" do
      data = SpecHelper.read_sample("moon.ppm")
      image = CrImage::RGBAImage.from_ppm(data)

      expect_digest(image.to_jpeg).to eq "456a54b4c2e0dc7f6751b28fb55ea0b26705ddb6"
    end

    it "works with GrayscaleImage" do
      data = SpecHelper.read_sample("moon.ppm")
      image = CrImage::GrayscaleImage.from_ppm(data)

      expect_digest(image.to_jpeg).to eq "9fefcb4b61444bbb0344bcab06f690641b34c4d2"
    end
  end

  describe "#to_ppm" do
    it "works with RGBAImage" do
      data = SpecHelper.read_sample("moon.ppm")
      image = CrImage::RGBAImage.from_ppm(data)

      expect_digest(image.to_jpeg).to eq "456a54b4c2e0dc7f6751b28fb55ea0b26705ddb6"
    end

    it "works with GrayscaleImage" do
      data = SpecHelper.read_sample("moon.ppm")
      image = CrImage::GrayscaleImage.from_ppm(data)

      expect_digest(image.to_jpeg).to eq "9fefcb4b61444bbb0344bcab06f690641b34c4d2"
    end
  end
end
