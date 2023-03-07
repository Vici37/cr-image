require "../spec_helper"

Spectator.describe CrImage::Mask do
  include SpecHelper

  alias Mask = CrImage::Mask

  def bits(size, int) : BitArray
    BitArray.new(size) { |i| int.bit(size - i - 1) > 0 }
  end

  it "initializes with width and height" do
    mask = Mask.new(3, 3)
    expect(mask.bits).to eq BitArray.new(9, true)
    expect(mask.size).to eq 9
  end

  it "initializes with bit array and width" do
    bits = BitArray.new(9, false)
    mask = Mask.new(3, bits)
    expect(mask.bits).to eq bits
    expect(mask.width).to eq 3
    expect(mask.height).to eq 3
    expect(mask.size).to eq 9
  end

  it "initializes with block" do
    mask = Mask.new(4, 4) { |x, y| (1..2).includes?(x) && (1..2).includes?(y) }
    expect(mask.size).to eq 16
    expect(mask.width).to eq 4
    expect(mask.height).to eq 4
    expect(mask[0.., 0..]).to eq [
      bits(4, 0b0000),
      bits(4, 0b0110),
      bits(4, 0b0110),
      bits(4, 0b0000),
    ]
  end

  it "initializes from integer" do
    mask = Mask.new(4, 4, 0b1010010110100101)
    expect(mask.size).to eq 16
    expect(mask.width).to eq 4
    expect(mask.height).to eq 4
    expect(mask[0.., 0..]).to eq [
      bits(4, 0b1010),
      bits(4, 0b0101),
      bits(4, 0b1010),
      bits(4, 0b0101),
    ]
  end

  it "raises if bit array size isn't evenly divisible by width" do
    expect_raises(Exception, /BitArray size 3 must be an even number of 2/) do
      Mask.new(2, BitArray.new(3))
    end
  end

  it "#[]" do
    bits = BitArray.new(4, false)
    bits[1] = true
    bits[3] = true

    # Mask looks like:
    # 0 1
    # 0 1

    mask = Mask.new(2, bits)
    expect(mask[0, 0]).to be_false
    expect(mask[1, 0]).to be_true
    expect(mask[0, 1]).to be_false
    expect(mask[1, 1]).to be_true
  end

  context "raises index error when" do
    let(mask) { Mask.new(2, BitArray.new(4)) }

    it "coordinate is outside of height" do
      expect_raises(IndexError, "Out of bounds: this mask is 2x2, and (0,2) is outside of that") do
        mask[0, 2]
      end
    end

    it "coordinate is outside of width" do
      expect_raises(IndexError, "Out of bounds: this mask is 2x2, and (2,0) is outside of that") do
        mask[2, 0]
      end
    end

    it "x range is outside of width" do
      expect_raises(IndexError, "Range 1..3 exceeds bounds of 2") do
        mask[1..3, 0]
      end
    end

    it "y range is outside of height" do
      expect_raises(IndexError, "Range 1..3 exceeds bounds of 2") do
        mask[1..3, 0]
      end
    end
  end

  context "using #[] with checkerboard pattern" do
    let(mask) { Mask.new(4, 4, 0b1010010110100101) }

    it "supports single point" do
      expect(mask[0, 0]).to be_true
      expect(mask[0, 1]).to be_false
      expect(mask[1, 0]).to be_false
      expect(mask[1, 1]).to be_true
      expect(mask[3, 3]).to be_true
    end

    it "supports range for x" do
      expect(mask[0..3, 0]).to eq bits(4, 0b1010)
      expect(mask[0..3, 1]).to eq bits(4, 0b0101)
      expect(mask[0..3, 2]).to eq bits(4, 0b1010)
      expect(mask[0..3, 3]).to eq bits(4, 0b0101)
    end

    it "supports range for y" do
      expect(mask[0, 0..3]).to eq bits(4, 0b1010)
      expect(mask[1, 0..3]).to eq bits(4, 0b0101)
      expect(mask[2, 0..3]).to eq bits(4, 0b1010)
      expect(mask[3, 0..3]).to eq bits(4, 0b0101)
    end

    it "supports finite range for both x and y" do
      expect(mask[0..3, 0..3]).to eq [
        bits(4, 0b1010),
        bits(4, 0b0101),
        bits(4, 0b1010),
        bits(4, 0b0101),
      ]
    end

    it "supports infinite range for both x and y" do
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1010),
        bits(4, 0b0101),
        bits(4, 0b1010),
        bits(4, 0b0101),
      ]
    end

    it "initializes from a larger mask" do
      other_mask = Mask.new(mask[1..2, 1..2])
      expect(other_mask[0..-1, 0..-1]).to eq [
        bits(2, 0b10),
        bits(2, 0b01),
      ]
    end

    it "has a region" do
      expect(mask.region).to eq CrImage::Region.new(0, 0, 4, 4)
    end
  end

  context "using #[] with unique pattern" do
    # Looks like:
    # 0000
    # 1110
    # 0110
    # 1001
    let(mask) { Mask.new(4, 4, 0b0000111001101001) }

    it "supports single point" do
      expect(mask[0, 0]).to be_false
      expect(mask[0, 1]).to be_true
      expect(mask[1, 0]).to be_false
      expect(mask[1, 1]).to be_true
      expect(mask[3, 3]).to be_true
    end

    it "supports range for x" do
      expect(mask[0..3, 0]).to eq bits(4, 0b0000)
      expect(mask[0..3, 1]).to eq bits(4, 0b1110)
      expect(mask[0..3, 2]).to eq bits(4, 0b0110)
      expect(mask[0..3, 3]).to eq bits(4, 0b1001)
    end

    it "supports range for y" do
      expect(mask[0, 0..3]).to eq bits(4, 0b0101)
      expect(mask[1, 0..3]).to eq bits(4, 0b0110)
      expect(mask[2, 0..3]).to eq bits(4, 0b0110)
      expect(mask[3, 0..3]).to eq bits(4, 0b0001)
    end

    it "supports finite range for both x and y" do
      expect(mask[0..3, 0..3]).to eq [
        bits(4, 0b0000),
        bits(4, 0b1110),
        bits(4, 0b0110),
        bits(4, 0b1001),
      ]
    end

    it "supports infinite range for both x and y" do
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b0000),
        bits(4, 0b1110),
        bits(4, 0b0110),
        bits(4, 0b1001),
      ]
    end

    it "initializes from a larger mask" do
      other_mask = Mask.new(mask[0..2, 1..2])
      expect(other_mask[0..-1, 0..-1]).to eq [
        bits(3, 0b111),
        bits(3, 0b011),
      ]
    end

    it "has a region" do
      expect(mask.region).to eq CrImage::Region.new(0, 1, 4, 3)
    end
  end

  it "#inverts" do
    mask = Mask.new(4, 4, 0b1010010110100101)
    expect(mask.invert).to eq Mask.new(4, 4, 0b0101101001011010)
    expect(mask).to eq Mask.new(4, 4, 0b1010010110100101)
  end

  context "using #[]= using checkerboard pattern" do
    it "sets a single point" do
      mask = Mask.new(4, 4, 0b1010010110100101)
      mask[1, 0] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1110),
        bits(4, 0b0101),
        bits(4, 0b1010),
        bits(4, 0b0101),
      ]

      mask[3, 2] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1110),
        bits(4, 0b0101),
        bits(4, 0b1011),
        bits(4, 0b0101),
      ]

      mask[1, 1] = false
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1110),
        bits(4, 0b0001),
        bits(4, 0b1011),
        bits(4, 0b0101),
      ]
    end

    it "sets range for x and single point for y" do
      mask = Mask.new(4, 4, 0b1010010110100101)
      mask[0..3, 0] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1111),
        bits(4, 0b0101),
        bits(4, 0b1010),
        bits(4, 0b0101),
      ]

      mask[1..2, 2] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1111),
        bits(4, 0b0101),
        bits(4, 0b1110),
        bits(4, 0b0101),
      ]

      mask[1..2, 2] = false
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1111),
        bits(4, 0b0101),
        bits(4, 0b1000),
        bits(4, 0b0101),
      ]
    end

    it "sets range for y and single point for x" do
      mask = Mask.new(4, 4, 0b1010010110100101)
      mask[0, 0..3] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1010),
        bits(4, 0b1101),
        bits(4, 0b1010),
        bits(4, 0b1101),
      ]

      mask[2, 1..2] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1010),
        bits(4, 0b1111),
        bits(4, 0b1010),
        bits(4, 0b1101),
      ]

      mask[2, 1..2] = false
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1010),
        bits(4, 0b1101),
        bits(4, 0b1000),
        bits(4, 0b1101),
      ]
    end

    it "sets range for both x and y" do
      mask = Mask.new(4, 4, 0b1010010110100101)
      mask[1..2, 1..2] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1010),
        bits(4, 0b0111),
        bits(4, 0b1110),
        bits(4, 0b0101),
      ]

      mask[0.., 0..] = true
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1111),
        bits(4, 0b1111),
        bits(4, 0b1111),
        bits(4, 0b1111),
      ]

      mask[1..2, 1..2] = false
      expect(mask[0.., 0..]).to eq [
        bits(4, 0b1111),
        bits(4, 0b1001),
        bits(4, 0b1001),
        bits(4, 0b1111),
      ]

      expect(mask.invert.region).to eq CrImage::Region.new(1, 1, 2, 2)
    end
  end

  context "with regions and segments" do
    let(mask) { Mask.new(4, 4, false) }

    it "creates an empty region" do
      expect(mask.region).to eq CrImage::Region.new(3, 3, 0, 0)
    end

    it "creates a region" do
      mask[1..2, 1..2] = true
      expect(mask.region).to eq CrImage::Region.new(1, 1, 2, 2)
      expect(mask.invert.region).to eq CrImage::Region.new(0, 0, 4, 4)
    end

    it "identifies no segments" do
      expect(mask.segments).to be_empty
    end

    it "identifies one segment" do
      mask[1..2, 1..2] = true
      expect(mask.segments.size).to eq 1
      expect(mask.segments[0]).to eq Mask.new(4, 4, 0b0000011001100000)
      expect(mask.segments[0].region).to eq CrImage::Region.new(1, 1, 2, 2)
    end

    it "identifies two segments" do
      mask[0, 0..] = true
      mask[3, 0..] = true

      expect(mask.segments.size).to eq 2
      expect(mask.segments[0]).to eq Mask.new(4, 4, 0b1000100010001000)
      expect(mask.segments[0].region).to eq CrImage::Region.new(0, 0, 1, 4)
      expect(mask.segments[1]).to eq Mask.new(4, 4, 0b0001000100010001)
      expect(mask.segments[1].region).to eq CrImage::Region.new(3, 0, 1, 4)
    end
  end

  it "converts to grayscale" do
    mask = Mask.new(4, 4, 0b1010010110100101)
    expect_digest(mask.to_gray).to eq "3f5741961d8c2290ca93988c23c7f13bc97c66aa"
  end
end
