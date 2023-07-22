#!/usr/bin/env -S crystal run
require "../src/cr-image"
require "../src/all_formats"

image = CrImage::RGBAImage.open("docs/images/sample.jpg")

# mask = CrImage::Mask.new(50, 50, false)
# mask[5..45, 5..45] = true
# mask[15..35, 15..35] = false
# mask[21..25, 21..25] = true
# mask[26..30, 26..30] = true

image.contrast(20).save("docs/images/contrasted_20_sample.jpg")
image.draw_square(40, 30, 80, 80, CrImage::Color.of("#00f")).save("docs/images/draw_square_40_30_80_80_sample.jpg")
image.draw_circle(80, 70, 40, CrImage::Color.of("#00f")).save("docs/images/draw_circle_80_70_40_sample.jpg")
image.draw_line(50, 50, 70, 90, CrImage::Color.of("#0f0")).save("docs/images/draw_line_50_50_70_90_sample.jpg")
image.gaussian_blur(1).save("docs/images/gaussian_1_sample.jpg")
image.gaussian_blur(5).save("docs/images/gaussian_5_sample.jpg")
image.horizontal_blur(1).save("docs/images/horizontal_1_sample.jpg")
image.horizontal_blur(5).save("docs/images/horizontal_5_sample.jpg")
image.vertical_blur(1).save("docs/images/vertical_1_sample.jpg")
image.vertical_blur(5).save("docs/images/vertical_5_sample.jpg")

mask = CrImage::Mask.new(image, false)
mask[50..90, 65..75] = true
mask.to_gray.save("docs/images/apply_mask_mask.jpg")
image.apply(mask).save("docs/images/apply_mask.jpg")
image.apply_color(mask, CrImage::Color.of("#00f")).save("docs/images/apply_mask_color.jpg")
image.apply(mask) do |pixel, channel_type|
  Math.min(255, pixel + 80).to_u8 if channel_type.blue?
end.save("docs/images/apply_mask_block.jpg")

image.to_gray.histogram_equalize.save("docs/images/gray_sample_equalized.jpg")

mask = image.to_gray < 128
mask.to_gray.save("docs/images/less_than_example.jpg")

image.pad(left: 50, right: 50).save("docs/images/pad_black.jpg")
image.pad(left: 50, right: 50, pad_type: CrImage::EdgePolicy::Repeat).save("docs/images/pad_repeat.jpg")
image.rotate(45).save("docs/images/rotate_45.jpg")
image.rotate(45, pad: true).save("docs/images/rotate_45_pad.jpg")

# This should only be run once to generate the sample picture
# colors = 256.times.to_a.map { |i| {i.to_u8, CrImage::Color.random} }.to_h
# image.to_gray.to_rgba(colors).save("docs/images/to_rgba_color_map_sample.jpg")
