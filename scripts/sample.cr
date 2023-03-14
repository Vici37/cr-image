#!/usr/bin/env -S crystal run
require "../src/cr-image"

image = CrImage::RGBAImage.open("docs/images/sample.jpg")

# image
#   .to_gray
#   .threshold(128)
#   .to_gray
#   .save("docs/images/mask_segments_example_original.jpg")
#   .threshold(128)
#   .segments
#   .each_with_index do |seg, i|
#     seg.to_gray.save("docs/images/mask_segments_example_#{i}.jpg")
#   end

mask = CrImage::Mask.new(50, 50, false)

mask[20, 20] = true
mask.to_gray.save("docs/images/mask_point.jpg")
mask[20..40, 20] = true
mask.to_gray.save("docs/images/mask_partial_row.jpg")
mask[.., ..] = false
mask[20, 20..40] = true
mask.to_gray.save("docs/images/mask_partial_column.jpg")
mask[.., ..] = false
mask[20..40, 20..40] = true
mask.to_gray.save("docs/images/mask_box.jpg")
