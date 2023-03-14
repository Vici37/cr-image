#!/usr/bin/env -S crystal run
require "../src/cr-image"

image = CrImage::RGBAImage.open("docs/images/sample.jpg")

mask = CrImage::Mask.new(50, 50, false)

mask[5..45, 5..45] = true
mask[15..35, 15..35] = false
mask[21..25, 21..25] = true
mask[26..30, 26..30] = true
mask.to_gray.save("mask_segments_example.jpg")

mask.segments.each_with_index do |segment, i|
  segment.to_gray.save("mask_8-way_segments_example_#{i}.jpg")
end

mask.segments(diagonal: false).each_with_index do |segment, i|
  segment.to_gray.save("mask_4-way_segments_example_#{i}.jpg")
end
