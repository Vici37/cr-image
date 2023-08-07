require "../spec_helper"

Spectator.describe CrImage::Color do
  include SpecHelper

  alias Color = CrImage::Color

  def color(red : UInt8, green : UInt8, blue : UInt8, alpha : UInt8) : Color
    Color.new(red, green, blue, alpha)
  end

  context "when parsing hex codes" do
    context "and parsing incorrect input" do
      it "raises when not starting with #" do
        expect_raises(Exception, /Invalid hex color 'nope'/) { Color.of("nope") }
      end

      it "raises when not correct size" do
        expect_raises(Exception, /Invalid hex color '#00000'/) { Color.of("#00000") }
        expect_raises(Exception, /Invalid hex color '#0000000'/) { Color.of("#0000000") }
        expect_raises(Exception, /Invalid hex color '#000000000'/) { Color.of("#000000000") }
      end

      it "raises if none a-f or 0-9 chars are used" do
        expect_raises(Exception, /'#g00'/) { Color.of("#g00") }
        expect_raises(Exception, /'#G00'/) { Color.of("#G00") }
      end
    end

    context "and parsing black" do
      it "parses 2 chars" do
        expect(Color.of("#0")).to eq color(0u8, 0u8, 0u8, 255u8)
      end

      it "parses 3 chars" do
        expect(Color.of("#00")).to eq color(0u8, 0u8, 0u8, 255u8)
      end

      it "parses 4 chars" do
        expect(Color.of("#000")).to eq color(0u8, 0u8, 0u8, 255u8)
      end

      it "parses 5 chars" do
        expect(Color.of("#0000")).to eq color(0u8, 0u8, 0u8, 0u8)
      end

      it "parses 7 chars" do
        expect(Color.of("#000000")).to eq color(0u8, 0u8, 0u8, 255u8)
      end

      it "parses 9 chars" do
        expect(Color.of("#00000000")).to eq color(0u8, 0u8, 0u8, 0u8)
      end
    end

    context "and parsing colors" do
      it "parses different values" do
        expect(Color.of("#004488bb")).to eq color(68u8, 136u8, 187u8, 0u8)
      end

      it "parses all white" do
        expect(Color.of("#ffffff")).to eq color(255u8, 255u8, 255u8, 255u8)
      end

      it "parses blue" do
        expect(Color.of("#00f")).to eq color(0u8, 0u8, 255u8, 255u8)
      end

      it "parses green" do
        expect(Color.of("#80f0")).to eq color(0u8, 255u8, 0u8, 136u8)
      end
    end
  end

  context "using channel type" do
    let(color) { Color.of("#23456789") }

    it "gets red channel" do
      expect(color[:red]).to eq 69u8
    end

    it "gets blue channel" do
      expect(color[:blue]).to eq 137u8
    end

    it "gets green channel" do
      expect(color[:green]).to eq 103u8
    end

    it "gets alpha channel" do
      expect(color[:alpha]).to eq 35u8
    end

    it "raises for gray channel" do
      expect(color[:gray]).to eq 96u8
    end
  end

  context "when calculating distances" do
    it "calculates euler distance by default" do
      expect(Color.of("#000001").dist(Color.of("#0"))).to eq 1
    end

    it "calculates euler distance even if negative" do
      expect(Color.of("#0").dist(Color.of("#000001"))).to eq 1
    end

    it "calculates max distance" do
      expect(Color.of("#f").dist(Color.of("#0")).round(6)).to eq 441.672956
    end

    it "calculates manahattan distance" do
      expect(Color.of("#0").dist(Color.of("#000001"), manhattan: true)).to eq 1
      expect(Color.of("#0").dist(Color.of("#010101"), manhattan: true)).to eq 3
      expect(Color.of("#0").dist(Color.of("#f"), manhattan: true)).to eq 765
    end
  end
end
