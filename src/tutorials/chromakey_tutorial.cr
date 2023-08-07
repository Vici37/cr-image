# Given `sample.jpg` image:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# We can swap out the background by creating a mask representing the pixels that are close in color, and replacing them using an `MaskApply#apply_color` method.
#
# ```
# require "cr-image"
# require "cr-image/jpeg"
#
# image = CrImage::RGBAImage.open("sample.jpg")
#
# # Grab a color from the background, for comparison
# background = image[10, 10]
#
# # Construct a mask of all pixels within a color distance of our background
# background_mask = image.mask_from do |color|
#   # 25 chosen through trial-and-error
#   color.dist(background) < 25
# end
#   .closing! # Remove small `true` regions
#   .opening! # Remove small `false` regions
#
# # Now make the background blue
# image
#   .apply_color(background_mask, CrImage::Color.of("#0000cc"))
#   .save("chromakey.jpg")
# ```
#
# Results in image:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/tutorials/chromakey.jpg" alt="Background is blue, woman is unchanged"/>
#
# This script ran on my machine in `4ms` in `--release` mode.
module Tutorial::ChromaKey
end
