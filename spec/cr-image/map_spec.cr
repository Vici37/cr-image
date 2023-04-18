require "../spec_helper"

Spectator.describe CrImage::Map do
  include SpecHelper

  alias IntMap = CrImage::IntMap
  alias FloatMap = CrImage::FloatMap

  context "when initializing" do
    it "constructs from array" do
      expect(IntMap.new(2, [2, 2]).size).to eq 2
    end

    it "raises if array isn't even multiple of width" do
      expect_raises(CrImage::Exception, /even multiple/) do
        IntMap.new(2, [1])
      end
    end

    it "constructs from array of arrays" do
      expect(IntMap.new([[1], [1], [1]]).size).to eq 3
    end

    it "raises if not all arrays are the same size" do
      expect_raises(CrImage::Exception, /must be the same size/) do
        IntMap.new([[1], [1, 2]])
      end
    end

    it "raises if passed in array is empty" do
      expect_raises(CrImage::Exception, /empty map/) do
        IntMap.new([] of Array(Int32))
      end
    end

    it "raises if passed in array of arrays starts with an empty array" do
      expect_raises(CrImage::Exception, /first array is empty/) do
        IntMap.new([[] of Int32])
      end
    end

    it "constructs using block" do
      expect(IntMap.new(2, 2) { |i| i % 2 }).to eq IntMap.new(2, [0, 1, 0, 1])
    end

    it "constructs with an initial value everywhere" do
      expect(IntMap.new(2, 2, 1)).to eq IntMap.new(2, [1, 1, 1, 1])
    end
  end

  it "calculates height" do
    expect(IntMap.new(2, [1, 1, 1, 1, 1, 1]).height).to eq 3
  end

  it "has size" do
    expect(IntMap.new(2, [1, 1, 1, 1, 1, 1]).size).to eq 6
  end

  context "with sample data" do
    let(map) { IntMap.new([
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

    # TODO: finish specs

    it "constructs a mask" do
      expect(map.mask_from { |i| (i % 2) == 0 }).to eq CrImage::Mask.new(3, 3, 0b1010101010)
    end

    it "makes mask from > threshold" do
      expect(map > 4).to eq CrImage::Mask.new(3, 3, 0b000011111)
    end

    it "makes mask from >= threshold" do
      expect(map >= 4).to eq CrImage::Mask.new(3, 3, 0b000111111)
    end

    it "makes mask from < threshold" do
      expect(map < 4).to eq CrImage::Mask.new(3, 3, 0b111000000)
    end

    it "makes mask from < threshold" do
      expect(map <= 4).to eq CrImage::Mask.new(3, 3, 0b111100000)
    end

    it "mask mask from ==" do
      expect(map == 4).to eq CrImage::Mask.new(3, 3, 0b000100000)
    end

    it "multiplies by a scalar" do
      expect(map * 2).to eq IntMap.new([
        [2, 4, 6],
        [8, 10, 12],
        [14, 16, 18],
      ])
    end

    it "multiplies by scalar is associative" do
      expect(2 * map).to eq IntMap.new([
        [2, 4, 6],
        [8, 10, 12],
        [14, 16, 18],
      ])
    end

    it "divides by a scalar" do
      expect(map / 2).to eq FloatMap.new([
        [0.5, 1.0, 1.5],
        [2.0, 2.5, 3.0],
        [3.5, 4.0, 4.5],
      ])
    end

    it "adds by scalar" do
      expect(map + 2).to eq IntMap.new([
        [3, 4, 5],
        [6, 7, 8],
        [9, 10, 11],
      ])
    end

    it "adds by scalar is associative" do
      expect(2 + map).to eq IntMap.new([
        [3, 4, 5],
        [6, 7, 8],
        [9, 10, 11],
      ])
    end

    it "subtracts scalar" do
      expect(map - 2).to eq IntMap.new([
        [-1, 0, 1],
        [2, 3, 4],
        [5, 6, 7],
      ])
    end

    it "substracts scalar (float)" do
      expect(map - 2.0).to eq FloatMap.new([
        [-1.0, 0.0, 1.0],
        [2.0, 3.0, 4.0],
        [5.0, 6.0, 7.0],

      ])
    end

    it "converts to GrayscaleImage without scaling" do
      expect_digest(map.to_gray(scale: false)).to eq "b187aebd54e5c74e6f680c889d00d5c4df3cf8c4"
    end

    it "converts to Grayscale and scales values" do
      expect_digest(map.to_gray).to eq "b187aebd54e5c74e6f680c889d00d5c4df3cf8c4"
    end

    it "uses method_missing to delegate to type's method (abs)" do
      expect(IntMap.new([
        [-1, 2, -3],
      ]).abs).to eq IntMap.new([[1, 2, 3]])
    end

    it "uses method_missing to delegate to type's method (round)" do
      expect(FloatMap.new([[0.4, 0.6]]).round).to eq FloatMap.new([[0.0, 1.0]])
    end
  end

  context "when cross correlating" do
    it "cross correlates 1x2" do
      original = IntMap.new([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ])
      map = IntMap.new([[-1, 2]])
      expect(original.cross_correlate(map)).to eq FloatMap.new([
        [1f64, 3f64, 4f64],
        [4f64, 6f64, 7f64],
        [7f64, 9f64, 10f64],
      ])
    end

    it "cross correlates 2x1" do
      original = IntMap.new([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ])
      map = IntMap.new([[-1], [2]])
      expect(original.cross_correlate(map)).to eq FloatMap.new([
        [1f64, 2f64, 3f64],
        [7f64, 8f64, 9f64],
        [10f64, 11f64, 12f64],
      ])
    end

    it "cross correlates with the error view" do
      original = IntMap.new([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ])
      map = IntMap.new([[-1], [2]])
      expect(original.cross_correlate(map, edge_policy: CrImage::EdgePolicy::None)).to eq FloatMap.new([
        [7f64, 8f64, 9f64],
      ])
    end

    it "does a full box blur" do
      map = IntMap.new([
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1],
      ])
      expect_digest(
        (gray_moon_ppm.cross_correlate(map) * 1/9).round.to_gray
      ).to eq "79f71e9be893d731c62b883926869a93b3246088"
    end
  end
end
