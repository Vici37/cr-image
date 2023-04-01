# Provides methods for histogram and histogram equalization. Follows method outlined [here](https://www.sci.utah.edu/~acoste/uou/Image/project1/Arthur_COSTE_Project_1_report.html)
#
# If an image is particularly dark or particularly bright with low contrast, the `Operation::Contrast#contrast` method will only
# make the image darker or lighter. For images like these, equalizing the image along its histogram will produce better results.
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mt_fuji.jpg" alt="A dark image of Mt. Fuji"/>
#
# ```
# image.contrast(10).save("contrast.jpg")
# image.histogram_equalize.save("equalized.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mt_fuji_contrast_10.jpg" alt="Darker image of Mt. Fuji"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mt_fuji_histogram_equalized.jpg" alt="A higher contrast image of Mt. Fuji"/>
#
# This method does not work well when a given method has a bimodal distribution of color pixels. For example:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample_equalized.jpg" alt="Highly pixelated and poor quality photo of woman in black turtleneck on white background in grayscale"/>
module CrImage::Operation::HistogramEqualize
  # A histogram of an `Image` for a specific `ChannelType`
  class Histogram
    getter image, channel_type

    def initialize(@image : Image, @channel_type : ChannelType)
    end

    @internal_hist : Hash(UInt8, Int32)?

    # Get the raw counts for a given pixel value (0-255) in the image
    def counts : Hash(UInt8, Int32)
      @internal_hist ||= calculate_counts
    end

    private def calculate_counts : Hash(UInt8, Int32)
      ret = Hash(UInt8, Int32).new { |h, k| h[k] = 0 }

      @image[@channel_type].each do |pixel|
        ret[pixel] += 1
      end

      ret.map(&.itself).sort!.to_h
    end

    @normalized_hist : Hash(UInt8, Float64)?

    # Get pixel counts normalized - all values between 0.0 and 1.0
    def normalize : Hash(UInt8, Float64)
      counts.map do |pixel, count|
        {pixel, count.to_f / @image.size}
      end.to_h
    end

    @cumulative_distribution_histogram : Hash(UInt8, Float64)?

    # Get the cumulative distribution for the image's histogram
    def cdf : Hash(UInt8, Float64)
      total = 0f64
      @cumulative_distribution_histogram ||= normalize.map do |pixel, probability|
        original = total
        total += probability
        {pixel, original}
      end.to_h
    end

    # Remap the cumalitive distribution of pixels to get a new, more spread out pixel value
    def equalize : Hash(UInt8, UInt8)
      cdf.map do |pixel, cumalative|
        {pixel, (cumalative * 255).clamp(0, 255).to_u8}
      end.to_h
    end

    @mean : Float64?

    def mean : Float64
      @mean ||= counts.sum { |pixel, count| pixel.to_i64 * count }.to_f64 / @image.size
    end

    @std_dev : Float64?

    def std_dev : Float64
      @std_dev ||= Math.sqrt(counts.sum { |value, count| count * (value.to_i64 - mean)**2 }.to_f64 / @image.size)
    end

    # :nodoc:
    # Still a work in progress
    # TODO: Finish this
    # def plot : RGBAImage
    #   probabilities = normalize.values
    #   max_prob = probabilities.max
    #   mult = 100 / max_prob

    #   w = 100 + 40
    #   h = 255 + 40

    #   init = Array(UInt8).new(w * h) { 255u8 }
    #   rgba = RGBAImage.new(init.clone, init.clone, init.clone, init.clone, w, h)
    #   rgba.draw_square!(19, 19, 101, 256, Color.of("#f00"))
    #   0.upto(255).each do |i|
    #     line_length = (hist[i]? || 0) * mult
    #     rgba.draw_square!(20, i + 20, line_length.to_i, 1, Color.of("#00f"))
    #   end

    #   rgba
    # end
  end

  def histogram(channel_type : ChannelType) : Histogram
    Histogram.new(self, channel_type)
  end

  def histogram_equalize : self
    clone.histogram_equalize!
  end

  def histogram_equalize! : self
    each_color_channel do |channel, channel_type|
      next if channel_type.alpha?
      remap = histogram(channel_type).equalize
      size.times do |i|
        channel.unsafe_put(i, remap[channel.unsafe_fetch(i)])
      end
    end
    self
  end
end
