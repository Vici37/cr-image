require "../../src/cr-image"
require "../../src/all_formats"
start = Time.monotonic

image = CrImage::RGBAImage.open("docs/images/tutorials/differences_start.jpg")
ret = image.clone

img1 = image.gaussian_blur(1)[2...340, ..]
img2 = image.gaussian_blur(1)[361...699, ..]

red_img1 = CrImage::UInt8Map.new(img1.width, img1.red).to_i
gre_img1 = CrImage::UInt8Map.new(img1.width, img1.green).to_i
blu_img1 = CrImage::UInt8Map.new(img1.width, img1.blue).to_i
red_img2 = CrImage::UInt8Map.new(img2.width, img2.red).to_i
gre_img2 = CrImage::UInt8Map.new(img2.width, img2.green).to_i
blu_img2 = CrImage::UInt8Map.new(img2.width, img2.blue).to_i

red_mask = (red_img1 - red_img2).abs.>(50)
gre_mask = (gre_img1 - gre_img2).abs.>(50)
blu_mask = (blu_img1 - blu_img2).abs.>(50)

combo_mask = (red_mask | blu_mask | gre_mask).dilate!

# Expensive way to make a thick box.
3.times do
  combo_mask.dilate!.segments.each do |v|
    ret.draw_square!(v.region.x + 2, v.region.y, v.region.width, v.region.height, CrImage::Color.of("#f00"))
    ret.draw_square!(v.region.x + 361, v.region.y, v.region.width, v.region.height, CrImage::Color.of("#f00"))
  end
end

ret.save("docs/images/tutorials/differences_end.jpg")

puts "Finished in #{Time.monotonic - start}"
