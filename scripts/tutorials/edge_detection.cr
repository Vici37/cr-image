require "../../src/cr-image"
require "../../src/all_formats"
start = Time.monotonic

# Edge Detection

vertical_sobel = CrImage::IntMap.new([
  [-1, -2, -1],
  [0, 0, 0],
  [1, 2, 1],
])

horizontal_sobel = CrImage::IntMap.new([
  [-1, 0, 1],
  [-2, 0, 2],
  [-1, 0, 1],
])

image = CrImage::GrayscaleImage.open("docs/images/sample.jpg")

dx = image.cross_correlate(horizontal_sobel)
dy = image.cross_correlate(vertical_sobel)

(dx ** 2 + dy ** 2).to_gray(scale: true).save("edge_detection.jpg")
puts "Finished in #{Time.monotonic - start}"
