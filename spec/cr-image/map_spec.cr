require "../spec_helper"
require "benchmark"

Spectator.describe CrImage::Map do
  include SpecHelper

  alias IntMap = CrImage::IntMap
  alias FloatMap = CrImage::FloatMap
  alias ComplexMap = CrImage::ComplexMap

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

    it "has a shape" do
      expect(map.shape).to eq({3, 3})
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

    it "passes method_missing arguments to type's method (** 2)" do
      expect(FloatMap.new([[2.0]]) ** 2).to eq FloatMap.new([[4.0]])
    end

    it "passes method_missing arguments to type's method (clamp)" do
      expect(FloatMap.new([[2.0, 0.0]]).clamp(0.5, 1.0)).to eq FloatMap.new([[1.0, 0.5]])
    end

    context "crops" do
      it "with range" do
        expect(map[1.., ..]).to eq IntMap.new([
          [2, 3],
          [5, 6],
          [8, 9],
        ])
        expect(map[.., ..]).to eq IntMap.new([
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
        expect(map[..1, ..1]).to eq IntMap.new([
          [1, 2],
          [4, 5],
        ])
        expect(map[1..1, 1..1]).to eq IntMap.new([
          [5],
        ])
      end

      it "column" do
        expect(map[1, ..]).to eq IntMap.new(1, [2, 5, 8])
      end

      it "row" do
        expect(map[1.., 1]).to eq IntMap.new([
          [5, 6],
        ])
      end

      it "gets row" do
        expect(map.row(1)).to eq IntMap.new([
          [4, 5, 6],
        ])
      end

      it "column" do
        expect(map.column(2)).to eq IntMap.new(1, [3, 6, 9])
      end
    end

    context "pads" do
      it "zero on the top" do
        expect(map.pad(top: 2)).to eq IntMap.new([
          [0, 0, 0],
          [0, 0, 0],
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
      end

      it "zero on the right" do
        expect(map.pad(right: 2)).to eq IntMap.new([
          [1, 2, 3, 0, 0],
          [4, 5, 6, 0, 0],
          [7, 8, 9, 0, 0],
        ])
      end

      it "zero on the bottom" do
        expect(map.pad(bottom: 2)).to eq IntMap.new([
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
          [0, 0, 0],
          [0, 0, 0],
        ])
      end

      it "zero on the left" do
        expect(map.pad(left: 2)).to eq IntMap.new([
          [0, 0, 1, 2, 3],
          [0, 0, 4, 5, 6],
          [0, 0, 7, 8, 9],
        ])
      end

      it "zero on all sides" do
        expect(map.pad(right: 2, left: 2, top: 1, bottom: 3)).to eq IntMap.new([
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 1, 2, 3, 0, 0],
          [0, 0, 4, 5, 6, 0, 0],
          [0, 0, 7, 8, 9, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0],
        ])
      end

      it "repeats on the top" do
        expect(map.pad(top: 2, pad_type: CrImage::EdgePolicy::Repeat)).to eq IntMap.new([
          [1, 2, 3],
          [1, 2, 3],
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
      end

      it "repeats on the right" do
        expect(map.pad(right: 2, pad_type: CrImage::EdgePolicy::Repeat)).to eq IntMap.new([
          [1, 2, 3, 3, 3],
          [4, 5, 6, 6, 6],
          [7, 8, 9, 9, 9],
        ])
      end

      it "repeats on the bottom" do
        expect(map.pad(bottom: 2, pad_type: CrImage::EdgePolicy::Repeat)).to eq IntMap.new([
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
          [7, 8, 9],
          [7, 8, 9],
        ])
      end

      it "repeats on the left" do
        expect(map.pad(left: 2, pad_type: CrImage::EdgePolicy::Repeat)).to eq IntMap.new([
          [1, 1, 1, 2, 3],
          [4, 4, 4, 5, 6],
          [7, 7, 7, 8, 9],
        ])
      end

      it "repeats on all sides" do
        expect(map.pad(right: 2, left: 2, top: 1, bottom: 3, pad_type: CrImage::EdgePolicy::Repeat)).to eq IntMap.new([
          [1, 1, 1, 2, 3, 3, 3],
          [1, 1, 1, 2, 3, 3, 3],
          [4, 4, 4, 5, 6, 6, 6],
          [7, 7, 7, 8, 9, 9, 9],
          [7, 7, 7, 8, 9, 9, 9],
          [7, 7, 7, 8, 9, 9, 9],
          [7, 7, 7, 8, 9, 9, 9],
        ])
      end
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

    it "does a full box blur with OneMap" do
      expect_digest(
        (gray_moon_ppm.cross_correlate(CrImage::OneMap.new(3, 3).to_intmap) * 1/9).round.to_gray
      ).to eq "79f71e9be893d731c62b883926869a93b3246088"
    end

    # The below are experiments and validations of implementing cross correlation through brute force
    # arithmetic, cross correlation using a discrete fourier transform, and cross correlation using a
    # fast fourier transform. Somehow the brute force arithmetic is still coming out as most
    # performant :/
    context "Compare cross correlation with brute force, and fft" do
      it "cross correlates with the error view" do
        original = IntMap.new([
          [1, 2, 3, 10],
          [4, 5, 6, 10],
          [7, 8, 9, 10],
          [7, 8, 9, 10],
        ])
        # Interesting, the input map (or original I suppose) must be symetrical like the below, or
        # get signs crossed?
        # map = IntMap.new([
        #   [4, 3, 5],
        #   [2, 1, 2],
        #   [5, 3, 4],
        # ])
        map = IntMap.new([
          [-1, 0, 1],
          [-2, 0, 2],
          [-1, 0, 1],
        ])

        CrImage::EdgePolicy.each do |edge_policy|
          expect(
            original.cross_correlate_fft(map, edge_policy: edge_policy)
              # remove rounding errors
              .round(13)
              # Fix sign differences (fft seems to want to have the opposite signs of non-fft :/)
              .abs
          ).to eq(
            original.cross_correlate(map, edge_policy: edge_policy)
              # remove rounding errors
              .round(13)
              # Fix sign differences (fft seems to want to have the opposite signs of non-fft :/)
              .abs
          )
        end

        # Keeping this, but commenting it out. Useful for comparing the fft and non-fft cross correlation implementations
        # puts "black"
        # puts original.cross_correlate(map, edge_policy: CrImage::EdgePolicy::Black).to_s
        # puts "fft black"
        # puts original.cross_correlate_fft(map, edge_policy: CrImage::EdgePolicy::Black).to_s

        # puts "repeat"
        # puts original.cross_correlate(map, edge_policy: CrImage::EdgePolicy::Repeat).to_s
        # puts "fft repeat"
        # puts original.cross_correlate_fft(map, edge_policy: CrImage::EdgePolicy::Repeat).to_s

        # puts "none"
        # puts original.cross_correlate(map, edge_policy: CrImage::EdgePolicy::None).to_s
        # puts "none"
        # puts original.cross_correlate_fft(map, edge_policy: CrImage::EdgePolicy::None).to_s
      end

      # Spec used for performance testing of the fast fourier transform 1d method. That method isn't exposed right now, so commenting this spec out.
      # it "does 1d fft", :focus do
      #   input = [0.393124, 0.071864, 0.713192, 0.588331, 0.254138, 0.974450, 0.280165, 0.547223, 0.413508, 0.410305, 0.146439, 0.363647, 0.779081, 0.872048, 0.843990, 0.452278, 0.870063, 0.487313, 0.966936, 0.167934, 0.598509, 0.753863, 0.535493, 0.807576, 0.424224, 0.843865, 0.366707, 0.892427, 0.383128, 0.042757, 0.400027, 0.641534, 0.162054, 0.996878, 0.495509, 0.730319, 0.412175, 0.870295, 0.030686, 0.664384, 0.677596, 0.763548, 0.079214, 0.965869, 0.471968, 0.951208, 0.151234, 0.113862, 0.950587, 0.645178, 0.236055, 0.569490, 0.610567, 0.817369, 0.842751, 0.999299, 0.619980, 0.121976, 0.616070, 0.229218, 0.277276, 0.659688, 0.900932, 0.630511, 0.314571, 0.754591, 0.327426, 0.057742, 0.312042, 0.305442, 0.510505, 0.163394, 0.593390, 0.813682, 0.001828, 0.948702, 0.829342, 0.096200, 0.907014, 0.212440, 0.878385, 0.675323, 0.408922, 0.342389, 0.090236, 0.834560, 0.599200, 0.997574, 0.464008, 0.289482, 0.448906, 0.872245, 0.625705, 0.755244, 0.377772, 0.226160, 0.750215, 0.634605, 0.635086, 0.433450, 0.724385, 0.874656, 0.748889, 0.822406, 0.343194, 0.018255, 0.865792, 0.728805, 0.675449, 0.691416, 0.618025, 0.161093, 0.396452, 0.590634, 0.503608, 0.489004, 0.834153, 0.995407, 0.185780, 0.551722, 0.098316, 0.954421, 0.066179, 0.677278, 0.360847, 0.166070, 0.115872, 0.661005, 0.686644, 0.305813, 0.135990, 0.635192, 0.806114, 0.064279, 0.500799, 0.805662, 0.596414, 0.216041, 0.124781, 0.521733, 0.033695, 0.624583, 0.872324, 0.225558, 0.223191, 0.813951, 0.042948, 0.517587, 0.188004, 0.996276, 0.002218, 0.990869, 0.419875, 0.921900, 0.352715, 0.599989, 0.010754, 0.113435, 0.176500, 0.471234, 0.844917, 0.806721, 0.361570, 0.124053, 0.282401, 0.094715, 0.215527, 0.045067, 0.673447, 0.460186, 0.414685, 0.137117, 0.411737, 0.308892, 0.705751, 0.965414, 0.792445, 0.625801, 0.648986, 0.122901, 0.165520, 0.501276, 0.531303, 0.456516, 0.912020, 0.141438, 0.045744, 0.589970, 0.369049, 0.166839, 0.295694, 0.507729, 0.257444, 0.686923, 0.371231, 0.972557, 0.252002, 0.358301, 0.682424, 0.380431, 0.234090, 0.547486, 0.226730, 0.259855, 0.533309, 0.739638, 0.637684, 0.524821, 0.190983, 0.872737, 0.568452, 0.008992, 0.076895, 0.501232, 0.961003, 0.120295, 0.577835, 0.470978, 0.994546, 0.374841, 0.396401, 0.996440, 0.168654, 0.848036, 0.396300, 0.740852, 0.586770, 0.133528, 0.664985, 0.887483, 0.002811, 0.148889, 0.269132, 0.519882, 0.105480, 0.542294, 0.409928, 0.427886, 0.911931, 0.951781, 0.361122, 0.670549, 0.097081, 0.003983, 0.167102, 0.264205, 0.402558, 0.617881, 0.534976, 0.013637, 0.857245, 0.628111, 0.171133, 0.563422, 0.798368, 0.435961, 0.298848, 0.441534, 0.528608, 0.587226, 0.595780, 0.421703, 0.767249, 0.830545, 0.574674, 0.283304, 0.005491, 0.786860, 0.416787, 0.238504, 0.367317, 0.220386, 0.965134, 0.700776, 0.819018, 0.037644, 0.595604, 0.437731, 0.535279, 0.572807, 0.579737, 0.973283, 0.496132, 0.382887, 0.011328, 0.336935, 0.113910, 0.504503, 0.818878, 0.464554, 0.461631, 0.281640, 0.957752, 0.105398, 0.476616, 0.130730, 0.940618, 0.860809, 0.001554, 0.133104, 0.734534, 0.951996, 0.148284, 0.080603, 0.234386, 0.956560, 0.080463, 0.716791, 0.840220, 0.434675, 0.411585, 0.388981, 0.137873, 0.866407, 0.995863, 0.201359, 0.613046, 0.297786, 0.988926, 0.181799, 0.225511, 0.106016, 0.631625, 0.540349, 0.090088, 0.048431, 0.549265, 0.818391, 0.133105, 0.931985, 0.707072, 0.105610, 0.205474, 0.997355, 0.272584, 0.138943, 0.789893, 0.947014, 0.089552, 0.329180, 0.927349, 0.195831, 0.620819, 0.624441, 0.576544, 0.171203, 0.360952, 0.931267, 0.304297, 0.188039, 0.921865, 0.676203, 0.140389, 0.430230, 0.415693, 0.049812, 0.524041, 0.435126, 0.901422, 0.268255, 0.632994, 0.386063, 0.299198, 0.271620, 0.765608, 0.012742, 0.758045, 0.135155, 0.231665, 0.096366, 0.730773, 0.138743, 0.600650, 0.164219, 0.969057, 0.248906, 0.036095, 0.469097, 0.078064, 0.163194, 0.546752, 0.489798, 0.884659, 0.215822, 0.090948, 0.720858, 0.014216, 0.412896, 0.414151, 0.144170, 0.065311, 0.340895, 0.776915, 0.279352, 0.943810, 0.463555, 0.122394, 0.614060, 0.063324, 0.735606, 0.552819, 0.698963, 0.764228, 0.827769, 0.067866, 0.589016, 0.746608, 0.736223, 0.753579, 0.540883, 0.199816, 0.009605, 0.671999, 0.086069, 0.784332, 0.740693, 0.635521, 0.917294, 0.624124, 0.074805, 0.360910, 0.449474, 0.729847, 0.536928, 0.617466, 0.203175, 0.279805, 0.163828, 0.971971, 0.892260, 0.288711, 0.557636, 0.425456, 0.556073, 0.205682, 0.578593, 0.334352, 0.634017, 0.868816, 0.064531, 0.268950, 0.330852, 0.959308, 0.331963, 0.058111, 0.953406, 0.806285, 0.374464, 0.696315, 0.716208, 0.579022, 0.257455, 0.036110, 0.426105, 0.667709, 0.964411, 0.690656, 0.081712, 0.325185, 0.166527, 0.893990, 0.828233, 0.221036, 0.647405, 0.052536, 0.185890, 0.835385, 0.353195, 0.358649, 0.658219, 0.886095, 0.904416, 0.459169, 0.849149, 0.601786, 0.790771, 0.213935, 0.770063, 0.896526, 0.236078, 0.208489, 0.930059, 0.185090, 0.895041, 0.210333, 0.695629, 0.040378, 0.537118, 0.255721, 0.706227, 0.863891, 0.437638, 0.930955, 0.332810, 0.295204, 0.237002, 0.842119, 0.064481, 0.305692, 0.489191, 0.227489, 0.930694, 0.784468, 0.267429, 0.833140, 0.274912, 0.467212, 0.003778, 0.946594, 0.835382, 0.291115, 0.045511, 0.748042, 0.732613, 0.284406, 0.293901, 0.699316, 0.159243, 0.608176, 0.978133, 0.854981, 0.624880, 0.145801, 0.187124, 0.778032, 0.558350, 0.861718, 0.942962, 0.766260, 0.487627, 0.931634, 0.911116, 0.252074, 0.815754, 0.762148, 0.812841, 0.382816, 0.142292, 0.802500, 0.693521, 0.617968, 0.501814, 0.543697, 0.936120, 0.438146, 0.476248, 0.354579, 0.585113, 0.195935, 0.542960, 0.249587, 0.578677, 0.518090, 0.331551, 0.875060, 0.491055, 0.739684, 0.906085, 0.368808, 0.511562, 0.050284, 0.530669, 0.111155, 0.052697, 0.650952, 0.570721, 0.770257, 0.795855, 0.477013, 0.054240, 0.444160, 0.889455, 0.602839, 0.456542, 0.373811, 0.281919, 0.310542, 0.021931, 0.138564, 0.663329, 0.363681, 0.201492, 0.486445, 0.775035, 0.119765, 0.674804, 0.107548, 0.243154, 0.247547, 0.985562, 0.454675, 0.451914, 0.632288, 0.796183, 0.839008, 0.785950, 0.470308, 0.148260, 0.163528, 0.028413, 0.279908, 0.953253, 0.020118, 0.314397, 0.740686, 0.980106, 0.525734, 0.111531, 0.937736, 0.118067, 0.791907, 0.195001, 0.817756, 0.311839, 0.585657, 0.465641, 0.432326, 0.126414, 0.814506, 0.866324, 0.876984, 0.763299, 0.744194, 0.093888, 0.940056, 0.140366, 0.325836, 0.657819, 0.941336, 0.182994, 0.097553, 0.203275, 0.710741, 0.859748, 0.416883, 0.176575, 0.328777, 0.575749, 0.847123, 0.488468, 0.498221, 0.099507, 0.241834, 0.871823, 0.921143, 0.237407, 0.925573, 0.699381, 0.301931, 0.844001, 0.327485, 0.212756, 0.107723, 0.906291, 0.834320, 0.980527, 0.754673, 0.163076, 0.785433, 0.737577, 0.022023, 0.890868, 0.216515, 0.066105, 0.747368, 0.251283, 0.225305, 0.569412, 0.259417, 0.673693, 0.937198, 0.743469, 0.200815, 0.035919, 0.863621, 0.184354, 0.372792, 0.990367, 0.703883, 0.495981, 0.159097, 0.378870, 0.947135, 0.184556, 0.696631, 0.124801, 0.118031, 0.093968, 0.148442, 0.313211, 0.282280, 0.868007, 0.847520, 0.798005, 0.842038, 0.484691, 0.916574, 0.000884, 0.709394, 0.745442, 0.299822, 0.995379, 0.779483, 0.234066, 0.684729, 0.335891, 0.570791, 0.738836, 0.419790, 0.732952, 0.565826, 0.041979, 0.995179, 0.608030, 0.150218, 0.241511, 0.477300, 0.418452, 0.855690, 0.957596, 0.192041, 0.111521, 0.032651, 0.291270, 0.253601, 0.505477, 0.284130, 0.761435, 0.634075, 0.746365, 0.296869, 0.619646, 0.740298, 0.886996, 0.230760, 0.919837, 0.255730, 0.200652, 0.049108, 0.230226, 0.825335, 0.760405, 0.229355, 0.717015, 0.973922, 0.101422, 0.977977, 0.618863, 0.170092, 0.571265, 0.375228, 0.315305, 0.212695, 0.476225, 0.929815, 0.130979, 0.961481, 0.629441, 0.345973, 0.399998, 0.986325, 0.369289, 0.862530, 0.187519, 0.799115, 0.472127, 0.126751, 0.920417, 0.731990, 0.590206, 0.256304, 0.422411, 0.533626, 0.671876, 0.802377, 0.269987, 0.256835, 0.481133, 0.628042, 0.451741, 0.774615, 0.400385, 0.933121, 0.717318, 0.656765, 0.913794, 0.124584, 0.252460, 0.145353, 0.365796, 0.088619, 0.899399, 0.319473, 0.741893, 0.387949, 0.308699, 0.817276, 0.759855, 0.106800, 0.312724, 0.514242, 0.103625, 0.004705, 0.694161, 0.700510, 0.779253, 0.098924, 0.220420, 0.652067, 0.477631, 0.109833, 0.369810, 0.245234, 0.022218, 0.966336, 0.061331, 0.436377, 0.601557, 0.096076, 0.376831, 0.716886, 0.972315, 0.136177, 0.723098, 0.801922, 0.044567, 0.802534, 0.409434, 0.321607, 0.724240, 0.223198, 0.176326, 0.168498, 0.834918, 0.676425, 0.323392, 0.022125, 0.337216, 0.385490, 0.908709, 0.504815, 0.522931, 0.600208, 0.628582, 0.848415, 0.640386, 0.969284, 0.606494, 0.677763, 0.922982, 0.139746, 0.831359, 0.600810, 0.918222, 0.553069, 0.051990, 0.720083, 0.105928, 0.237551, 0.728931, 0.076583, 0.466656, 0.153292, 0.773673, 0.312091, 0.161898, 0.843535, 0.802060, 0.653069, 0.064042, 0.570146, 0.541882, 0.214646, 0.879609, 0.848273, 0.553615, 0.625212, 0.336382, 0.470202, 0.181405, 0.922778, 0.867832, 0.154295, 0.874677, 0.765939, 0.084585, 0.060316, 0.738187, 0.494593, 0.117947, 0.192105, 0.265911, 0.919415, 0.305896, 0.098744, 0.775365, 0.839694, 0.780726, 0.714929, 0.664508, 0.816282, 0.856720, 0.054624, 0.195632, 0.844038, 0.409502, 0.033811, 0.956611, 0.902132, 0.151331, 0.224606, 0.671425, 0.729718, 0.250378, 0.062198, 0.839713, 0.280374, 0.214897, 0.125921, 0.014575, 0.625395, 0.823414, 0.340114, 0.730806, 0.558422, 0.802023, 0.112185, 0.385402, 0.436650, 0.600349, 0.955789, 0.292548, 0.842510, 0.344487, 0.355460, 0.976120, 0.667134, 0.286574, 0.095893, 0.312139, 0.841253, 0.108206, 0.968945, 0.734377, 0.386839, 0.275920, 0.499855, 0.033594, 0.354604, 0.951200, 0.974064, 0.232026, 0.605493, 0.809578, 0.145085, 0.188990, 0.908350, 0.813098, 0.217982, 0.518485, 0.572376, 0.092490, 0.459645, 0.751973, 0.409919, 0.411096, 0.002950, 0.861745, 0.246773, 0.569840, 0.041638, 0.393083, 0.173031, 0.832401, 0.555129, 0.466317, 0.890813, 0.310289, 0.415670, 0.051443, 0.756847, 0.535025, 0.478883, 0.749595, 0.918984, 0.357806, 0.449713, 0.272515, 0.261996, 0.611501, 0.922422, 0.887135, 0.982229, 0.509368, 0.133963, 0.323079, 0.621511, 0.366196, 0.235674, 0.053168, 0.684505, 0.507212, 0.222110, 0.848678, 0.771645, 0.520857, 0.394024, 0.706591, 0.385850, 0.655048, 0.313964, 0.883871, 0.052236, 0.649678, 0.947018, 0.905546, 0.014976, 0.238003, 0.768622, 0.477395, 0.702998, 0.751870, 0.320890, 0.400370]
      #   start = Time.monotonic
      #   fft = CrImage::MapImpl.fft1d(input)
      #   puts(Time.monotonic - start)
      #   expect(CrImage::ComplexMap.ifft1d(fft).map(&.real.round(6))).to eq input
      # end
    end
  end
end
