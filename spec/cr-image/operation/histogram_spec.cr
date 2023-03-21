require "../../spec_helper"
require "benchmark"

Spectator.describe CrImage::Operation::Histogram do
  include SpecHelper

  let(image) { CrImage::GrayscaleImage.open("docs/images/sample.jpg") }

  it "histograms", :focus do
    # gray = image.threshold(8).region.crop(image)
    # gray = CrImage::GrayscaleImage.open("test.png")
    gray = CrImage::GrayscaleImage.open("mt_fuji.jpg")
    # pp! gray.histogram(:gray)
    # pp! gray.normalized_histogram(:gray)
    # pp! gray.cumulative_distribution_histogram(:gray)
    # pp! gray.histogram_equalize(:gray)
    gray.save("original.png")
    equalized = gray.histogram_equalize_image.save("equalized.png")
    # pp! gray.histogram_equalize_image.normalized_histogram(:gray)
    gray.draw_histogram(:gray).save("original_histogram.png")
    equalized.draw_histogram(:gray).save("equalized_histogram.png")
    gray.contrast(10).save("contrast.png")
    # verify = CrImage::GrayscaleImage.open("test.png")
    # equalized.gray.each_with_index do |val, i|
    #   pp! val, verify.gray[i]
    # end
  end
end
