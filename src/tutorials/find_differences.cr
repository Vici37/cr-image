# Given `differences.jpg` image:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/tutorials/differences_start.jpg" alt="Two almost identical images with subtle differences"/>
#
# We can programatically detect _most_ of the differences between these two images:
#
# ```
# require "../../src/cr-image"
# require "../../src/all_formats"
#
# image = CrImage::RGBAImage.open("differences.jpg")
# ret = image.clone
#
# # Perform a blur to remove random noise
# img1 = image.gaussian_blur(1)[2...340, ..]
# img2 = image.gaussian_blur(1)[361...699, ..]
#
# # Convert each color channel into a IntMap
# red_img1 = CrImage::UInt8Map.new(img1.width, img1.red).to_i
# gre_img1 = CrImage::UInt8Map.new(img1.width, img1.green).to_i
# blu_img1 = CrImage::UInt8Map.new(img1.width, img1.blue).to_i
# red_img2 = CrImage::UInt8Map.new(img2.width, img2.red).to_i
# gre_img2 = CrImage::UInt8Map.new(img2.width, img2.green).to_i
# blu_img2 = CrImage::UInt8Map.new(img2.width, img2.blue).to_i
#
# # Calculate a pixel by pixel difference calculation, convert it to a `Mask`
# red_mask = (red_img1 - red_img2).abs.>(50)
# gre_mask = (gre_img1 - gre_img2).abs.>(50)
# blu_mask = (blu_img1 - blu_img2).abs.>(50)
#
# # Combine the different color channel masks
# combo_mask = (red_mask | blu_mask | gre_mask).dilate!
#
# # Expensive way to make a thick box.
# 3.times do
#   combo_mask.dilate!.segments.each do |v|
#     # Draw a box in the first image
#     ret.draw_square!(v.region.x + 2, v.region.y, v.region.width, v.region.height, CrImage::Color.of("#f00"))
#     # ... and the second image
#     ret.draw_square!(v.region.x + 361, v.region.y, v.region.width, v.region.height, CrImage::Color.of("#f00"))
#   end
# end
#
# ret.save("differences_end.jpg")
# ```
#
# Results in image:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/tutorials/differences_end.jpg" alt="Two images with subtle differences outlined in red boxes"/>
#
# This script ran on my machine in `66ms` in `--release` mode.
#
# **NODE**: There's a difference in the seeds on one of the watermelons that don't survive the blurring process, and so aren't picked
# up by the differences algorithm above.
module Tutorial::ChromaKey
end
