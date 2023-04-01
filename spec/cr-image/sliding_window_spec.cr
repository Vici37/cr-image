require "../spec_helper"

Spectator.describe CrImage::SlidingWindow do
  include SpecHelper

  it "does a thing", :focus do
    # map = CrImage::Int32Map.new(3, [
    #   1, 2, 1,
    #   2, 4, 2,
    #   1, 2, 1,
    # ])
    # map = CrImage::Int32Map.new(3, [
    #   1, 1, 1,
    #   1, 1, 1,
    #   1, 1, 1,
    # ])
    map = CrImage::Int32Map.new(3, [
      -1, 0, 1,
      -2, 0, 2,
      -1, 0, 1,
    ])

    image = gray_moon_ppm
    image.crop!(image.threshold(16).region).save("original.ppm")
    start = Time.monotonic
    f = CrImage::SlidingWindow.new(map, image).slide
    puts "Sliding took #{(Time.monotonic - start).total_milliseconds}"
    # CrImage::GrayscaleImage.new(f.raw.map(&.to_u8), f.width).save("box_blur.ppm")
    f.mask_from { |_, _, v| v.abs > 50 }.to_gray.save("horizontal_edge.ppm")
    start = Time.monotonic
    ni = image.box_blur(1)
    puts "Box blur took #{(Time.monotonic - start).total_milliseconds}"
    ni.save("real_box_blur.ppm")
  ensure
    puts "All done"
  end
end
