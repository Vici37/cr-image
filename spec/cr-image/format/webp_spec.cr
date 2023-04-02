require "../../spec_helper"

Spectator.describe CrImage::Format::WebP do
  include SpecHelper

  let(memory) { IO::Memory.new }

  describe ".from_webp and #to_webp" do
    it "works with GrayscaleImage" do
      with_sample("scenic/moon.webp") do |io|
        image = CrImage::GrayscaleImage.from_webp(io)
        image.to_webp(memory)

        expect_digest(memory.to_s).to eq "da91af4ce7c62f30e2f4a0fc7abda931ea57836e"
      end
    end

    it "works with RGBAImage" do
      with_sample("scenic/moon.webp") do |io|
        image = CrImage::RGBAImage.from_webp(io)
        image.to_webp(memory)

        expect_digest(memory.to_s).to eq "308ce25679db4538c210831e613a7d5dd8a77b49"
      end
    end
  end

  describe "lossy #to_webp" do
    it "works with RGBAImage" do
      rgba_moon_ppm.to_webp(memory, lossy: true)
      expect_digest(memory.to_s).to eq "9fcf92ebaa452af499241e708cf0524990a58a2b"
    end

    it "works with GrayscaleImage" do
      gray_moon_ppm.to_webp(memory, lossy: true)
      expect_digest(memory.to_s).to eq "57cd10335d2d5beb77d44f984a414c1d6d976c54"
    end

    context "with quality param" do
      it "works with RGBAImage" do
        rgba_moon_ppm.to_webp(memory, lossy: true, quality: 50)
        expect_digest(memory.to_s).to eq "609ade72a959e7a40cd44373f6bc90801feb4a76"
      end

      it "works with GrayscaleImage" do
        gray_moon_ppm.to_webp(memory, lossy: true, quality: 50)
        expect_digest(memory.to_s).to eq "0bbeaca641264ad4269a9b68815d712ec92154c9"
      end
    end
  end
end
