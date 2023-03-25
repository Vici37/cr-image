require "../../spec_helper"
require "benchmark"

Spectator.describe CrImage::Operation::Histogram do
  include SpecHelper

  specs_for_operator(histogram_equalize,
    gray_hash: "5109c626e06ad5704586ce0533e89d7e245f27f9",
    rgba_hash: "2e9f59da8d221654f4e1b4446539d1d6bb648c9b"
  )

  specs_for_operator(histogram_equalize!,
    gray_hash: "5109c626e06ad5704586ce0533e89d7e245f27f9",
    rgba_hash: "2e9f59da8d221654f4e1b4446539d1d6bb648c9b"
  )

  context "when making calculations" do
    let(image) { gray_moon_ppm }
    it "for the mean" do
      expect(image.histogram(:gray).mean).to eq 19.500419285340097
    end

    it "for the standard deviation" do
      expect(image.histogram(:gray).std_dev).to eq 2.324456
    end
  end
end
