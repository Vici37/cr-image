require "../spec_helper"

Spectator.describe CrImage::RGBAImage do
  include SpecHelper

  alias Color = CrImage::Color

  let(image) { rgba_light_background_ppm }
  let(gray) { gray_light_background_ppm }

  it "initializes" do
    red = [0u8, 1u8]
    green = [2u8, 3u8]
    blue = [4u8, 5u8]
    alpha = [6u8, 7u8]
    width = 2
    height = 1

    expect(CrImage::RGBAImage.new(red, green, blue, alpha, width, height)).to be_truthy
  end

  it "converts to grayscale" do
    expect_digest(image.to_gray).to eq "018104150439c0647e0b4f55403a3b1390308ecf"
  end

  it "converts to rgba" do
    expect_digest(gray.to_rgba).to eq "018104150439c0647e0b4f55403a3b1390308ecf"
  end

  it "converts to rgba with an empty color map with white default" do
    colors = {} of UInt8 => Color

    expect_digest(gray.to_rgba(colors, default: Color.of("#fff"))).to eq "34787e7385235c5872fa700de63517f79f07fd8a"
  end

  it "converts to rgba with color map" do
    colors = {} of UInt8 => Color
    256.times do |i|
      colors[i.to_u8] = Color.new((i * 0.299).to_u8, (i * 0.587).to_u8, (i * 0.114).to_u8, 255u8)
    end
    expect_digest(gray.to_rgba(colors)).to eq "89de65f63d9c21f62dee5a1a606cce5b20dd4dc4"
  end
end
