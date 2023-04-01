require "../../spec_helper"

Spectator.describe CrImage::Operation::MaskApply do
  include SpecHelper

  describe "#apply" do
    describe "with Grayscale" do
      let(image) { gray_moon_ppm }
      let(mask) { CrImage::Mask.new(image) }

      it "changes nothing when initialized as all true" do
        expect_digest(image.apply(mask)).to eq "62d6101d60ee8da38d1b9d8e809091099cec5994"
      end

      it "blacks out half the image" do
        mask[0..(image.width//2), 0..] = false
        expect_digest(image.apply(mask)).to eq "25b87524aa9dac4053ccb93264cdf17be238a159"
      end

      it "applies threshold from >= operator" do
        expect_digest(image.apply(image >= 16)).to eq "395b623395ef7c3e8cb93da9f1aaad899ebe2f57"
      end

      it "applies threshold from >= operator" do
        expect_digest(image.apply(image > 16)).to eq "395b623395ef7c3e8cb93da9f1aaad899ebe2f57"
      end

      it "applies threshold from < operator" do
        expect_digest(image.apply(image < 16)).to eq "b043cb7b345fbddac8e5770cf3e2847cba305563"
      end

      it "applies threshold from <= operator" do
        expect_digest(image.apply(image <= 16)).to eq "b043cb7b345fbddac8e5770cf3e2847cba305563"
      end

      it "applies threshold" do
        expect_digest(image.apply(image.threshold(16))).to eq "395b623395ef7c3e8cb93da9f1aaad899ebe2f57"
      end

      it "applies threshold through mask" do
        expect_digest(image.threshold(16).apply(image)).to eq "395b623395ef7c3e8cb93da9f1aaad899ebe2f57"
      end
    end

    describe "with RGBAImage" do
      let(image) { rgba_moon_ppm }
      let(mask) { CrImage::Mask.new(image) }

      it "changes nothing when initialized as all true" do
        expect_digest(image.apply(mask)).to eq "d764459f778b4839972367f78197bf9a96cd11fd"
      end

      it "blacks out half the image" do
        mask[0..(image.width//2), 0..] = false
        expect_digest(image.apply(mask)).to eq "9c052b5ce181ed6f48db8ec7596080de26d0ea24"
      end

      it "applies threshold" do
        expect_digest(image.apply(image.to_gray.threshold(16))).to eq "f1f81947893606efad2d929184182aaa4e7531d0"
      end

      it "applies threshold through mask" do
        expect_digest(image.to_gray.threshold(16).apply(image)).to eq "f1f81947893606efad2d929184182aaa4e7531d0"
      end

      it "draws a blue moon" do
        expect_digest(
          image
            .to_gray
            .threshold(16)
            .apply(image) do |_, channel_type|
              channel_type == CrImage::ChannelType::Blue ? 255u8 : 0u8
            end
        ).to eq "43e81fcc7860668fdeb0c125a863f8b2e2d5b315"
      end
    end
  end

  describe "#apply_color" do
    let(image) { rgba_moon_ppm }
    let(color) { CrImage::Color.of("#00f") }

    it "turns the moon blue" do
      expect_digest(image.apply_color(
        image.to_gray.threshold(8),
        color
      )).to eq "afb6ca5a5f8ab6e71ca306eeeada89dcd3be99a5"
    end
  end
end
