require "../../spec_helper"

Spectator.describe CrImage::Operation::VerticalBlur do
  describe "#vertical_blur" do
    it "works with RGBAImage" do
      data = SpecHelper.read_sample("pluto.ppm")

      original_image = CrImage::RGBAImage.from_ppm(data)
      blurred_image = original_image.vertical_blur(10)

      Digest::SHA1.hexdigest(original_image.to_ppm).should eq "d7fa6faf6eec5350f8de8b41f478bf7e8d217fa9"
      Digest::SHA1.hexdigest(blurred_image.to_ppm).should eq "d7116d6cea0a14e23cc3a23dbc86ad8bf1fecf2f"
    end

    it "works with GrayscaleImage" do
      data = SpecHelper.read_sample("pluto.ppm")

      original_image = CrImage::GrayscaleImage.from_ppm(data)
      blurred_image = original_image.vertical_blur(10)

      Digest::SHA1.hexdigest(original_image.to_ppm).should eq "1a4d4e43e17f3245cefe5dd2c002fb85de079ae8"
      Digest::SHA1.hexdigest(blurred_image.to_ppm).should eq "38d71a5c13f46afdca6b13ecbdeb97327cd46dd7"
    end
  end

  describe "#vertical_blur!" do
    it "works with RGBAImage" do
      data = SpecHelper.read_sample("pluto.ppm")

      image = CrImage::RGBAImage.from_ppm(data)
      image.vertical_blur!(10)

      Digest::SHA1.hexdigest(image.to_ppm).should eq "d7116d6cea0a14e23cc3a23dbc86ad8bf1fecf2f"
    end

    it "works with GrayscaleImage" do
      data = SpecHelper.read_sample("pluto.ppm")

      image = CrImage::GrayscaleImage.from_ppm(data)
      image.vertical_blur!(10)

      Digest::SHA1.hexdigest(image.to_ppm).should eq "38d71a5c13f46afdca6b13ecbdeb97327cd46dd7"
    end
  end
end
