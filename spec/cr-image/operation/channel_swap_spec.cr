require "../../spec_helper"

Spectator.describe CrImage::Operation::ChannelSwap do
  include SpecHelper

  describe CrImage::RGBAImage do
    let(image) { rgba_moon_ppm }

    it "#channel_swap" do
      expect_digest(image.channel_swap(:red, :blue)).to eq "d764459f778b4839972367f78197bf9a96cd11fd"
    end

    it "#channel_swap!" do
      expect_digest(image.channel_swap!(:red, :blue)).to eq "d764459f778b4839972367f78197bf9a96cd11fd"
    end
  end

  it "works with GrayscaleImage" do
    expect_raises(Exception, /Unknown channel type Red for GrayscaleImage/) do
      gray_moon_ppm.channel_swap(:red, :blue)
    end
  end
end
