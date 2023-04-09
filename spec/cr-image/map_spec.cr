require "../spec_helper"

Spectator.describe CrImage::Map do
  include SpecHelper

  context "when initializing" do
    it "constructs from array" do
      expect(CrImage::IntMap.new(2, [2, 2]).size).to eq 2
    end

    it "raises if array isn't even multiple of width" do
      expect_raises(CrImage::Exception, /even multiple/) do
        CrImage::IntMap.new(2, [1])
      end
    end

    it "constructs from array of arrays" do
      expect(CrImage::IntMap.new([[1], [1], [1]]).size).to eq 3
    end

    it "raises if not all arrays are the same size" do
      expect_raises(CrImage::Exception, /must be the same size/) do
        CrImage::IntMap.new([[1], [1, 2]])
      end
    end

    it "raises if passed in array is empty" do
      expect_raises(CrImage::Exception, /empty map/) do
        CrImage::IntMap.new([] of Array(Int32))
      end
    end

    it "raises if passed in array of arrays starts with an empty array" do
      expect_raises(CrImage::Exception, /first array is empty/) do
        CrImage::IntMap.new([[] of Int32])
      end
    end

    it "constructs using block" do
      expect(CrImage::IntMap.new(2, 2) { |i| i % 2 }).to eq CrImage::IntMap.new(2, [0, 1, 0, 1])
    end

    it "constructs with an initial value everywhere" do
      expect(CrImage::IntMap.new(2, 2, 1)).to eq CrImage::IntMap.new(2, [1, 1, 1, 1])
    end
  end

  it "calculates height" do
    expect(CrImage::IntMap.new(2, [1, 1, 1, 1, 1, 1]).height).to eq 3
  end

  it "has size" do
    expect(CrImage::IntMap.new(2, [1, 1, 1, 1, 1, 1]).size).to eq 6
  end

  context "with sample data" do
    let(map) { CrImage::IntMap.new([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ]) }

    it "gets by index" do
      expect(map[0]).to eq 1
      expect(map[1]).to eq 2
      expect(map[2]).to eq 3
      expect(map[3]).to eq 4
      expect(map[4]).to eq 5
      expect(map[5]).to eq 6
      expect(map[6]).to eq 7
      expect(map[7]).to eq 8
      expect(map[8]).to eq 9
    end

    it "gets by coordinates" do
      expect(map[0, 0]).to eq 1
      expect(map[1, 1]).to eq 5
      expect(map[2, 2]).to eq 9
    end

    it "raises coordinates are outside of map" do
      expect_raises(CrImage::Exception, /outside of Map width/) { map[-1, 0] }
      expect_raises(CrImage::Exception, /outside of Map width/) { map[3, 0] }
      expect_raises(CrImage::Exception, /outside of Map height/) { map[0, -1] }
      expect_raises(CrImage::Exception, /outside of Map height/) { map[0, 3] }
    end

    it "gets nil from nonexistent index" do
      expect(map[9]?).to be_nil
    end

    it "gets nil from nonexistent coordinate" do
      expect(map[-1, 0]?).to be_nil
      expect(map[3, 0]?).to be_nil
      expect(map[0, -1]?).to be_nil
      expect(map[0, 3]?).to be_nil
    end

    it "calculates the average" do
      expect(map.mean).to eq 5
    end

    it "finds the minimum value" do
      expect(map.min).to eq 1
    end

    it "finds the maximum value" do
      expect(map.max).to eq 9
    end

    it "finds the sum of all values" do
      expect(map.sum).to eq 45
    end
  end

  it "does a thing" do
    # map = CrImage::IntMap.new(3, [
    #   1, 2, 1,
    #   2, 4, 2,
    #   1, 2, 1,
    # ])
    map = CrImage::IntMap.new(3, [
      1, 1, 1,
      1, 1, 1,
      1, 1, 1,
    ])
    # map = CrImage::IntMap.new(3, [
    #   -1, 0, 1,
    #   -2, 0, 2,
    #   -1, 0, 1,
    # ])

    image = gray_moon_ppm
    image.crop!(image.threshold(16).region).save("original.ppm")
    # start = Time.monotonic
    # f = CrImage::SlidingWindow.new(map, image).slide
    f = map * image * 1/9
    # puts "Sliding took #{(Time.monotonic - start).total_milliseconds}"
    sliding = CrImage::GrayscaleImage.new(f.raw.map(&.round.to_u8), f.width)
    f.abs.to_gray.save("to_gray.ppm")
    # sliding.save("box_blur.ppm")
    expect_digest(sliding).to eq "c90987a619dd75914eb23cc9c67f80f0a80d9601"
    # pp! sliding.gray[0, 25]
    # pp! sliding.gray[84, 20]
    # pp! sliding.gray[168, 20]
    # # f.mask_from { |v| v.abs > 50 }.to_gray.save("horizontal_edge.ppm")
    # start = Time.monotonic
    # orig_im = image.box_blur(1)
    # pp! orig_im.gray[0, 25]
    # pp! orig_im.gray[84, 20]
    # pp! orig_im.gray[168, 20]
    # expect_digest(orig_im).to eq "7c34b7d6a9f68a1d81039c91d9cecef22aaef263"
    # puts "Box blur took #{(Time.monotonic - start).total_milliseconds}"
    # orig_im.save("real_box_blur.ppm")
  end
end
