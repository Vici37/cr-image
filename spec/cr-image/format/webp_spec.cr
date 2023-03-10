require "../../spec_helper"

Spectator.describe CrImage::Format::WebP do
  include SpecHelper

  describe ".from_webp and #to_webp" do
    it "works with GrayscaleImage" do
      with_sample("scenic/moon.webp") do |io|
        image = CrImage::GrayscaleImage.from_webp(io)
        io = IO::Memory.new
        image.to_webp(io)

        expect_digest(io.to_s).to eq "da91af4ce7c62f30e2f4a0fc7abda931ea57836e"
      end
    end

    it "works with RGBAImage" do
      with_sample("scenic/moon.webp") do |io|
        image = CrImage::RGBAImage.from_webp(io)
        io = IO::Memory.new
        image.to_webp(io)

        expect_digest(io.to_s).to eq "308ce25679db4538c210831e613a7d5dd8a77b49"
      end
    end
  end
end
