#!/usr/bin/env -S crystal run
require "../src/cr-image"

image = CrImage::RGBAImage.open("docs/images/sample.jpg")

# mask = CrImage::Mask.new(50, 50, false)
# mask[5..45, 5..45] = true
# mask[15..35, 15..35] = false
# mask[21..25, 21..25] = true
# mask[26..30, 26..30] = true

image.box_blur(1).save("blurred_1_sample.jpg")
image.box_blur(5).save("blurred_5_sample.jpg")
