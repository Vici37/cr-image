require "../../src/cr-image"
require "../../src/all_formats"
start = Time.monotonic

image = CrImage::RGBAImage.open("docs/images/sample.jpg")

# Grab a color from the background, for comparison
background = image[10, 10]

# Construct a mask of all pixels within a color distance of our background
background_mask = image.mask_from do |color|
  # 25 chosen through trial-and-error
  color.dist(background) < 25
end
  .closing! # Remove small `true` regions
  .opening! # Remove small `false` regions

# Now make the background blue
image.apply_color(background_mask, CrImage::Color.of("#0000cc")).save("chromakey.jpg")

puts "Finished in #{Time.monotonic - start}"
