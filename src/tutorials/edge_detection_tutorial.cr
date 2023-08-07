# Given `sample.jpg` image:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# We can run the [Sobel Operator](https://en.wikipedia.org/wiki/Sobel_operator) to detect edges in it:
#
# ```
# require "cr-image"
# require "cr-image/jpeg"
#
# vertical_sobel = CrImage::IntMap.new([
#   [-1, -2, -1],
#   [0, 0, 0],
#   [1, 2, 1],
# ])
#
# horizontal_sobel = CrImage::IntMap.new([
#   [-1, 0, 1],
#   [-2, 0, 2],
#   [-1, 0, 1],
# ])
#
# image = CrImage::GrayscaleImage.open("sample.jpg")
#
# dx = image.cross_correlate(horizontal_sobel)
# dy = image.cross_correlate(vertical_sobel)
#
# (dx ** 2 + dy ** 2).to_gray(scale: true).save("edge_detection.jpg")
# ```
#
# Results in image:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/tutorials/edge_detection.jpg" alt="Black image with white outline of woman"/>
#
# This script ran on my machine in `11ms` in `--release` mode.
#
# **Note**: This tutorial is using `cross_correlate`. For large images (or medium-to-large operators), the `cross_correlate_fft` may perform better.
module Tutorial::EdgeDetection
end
