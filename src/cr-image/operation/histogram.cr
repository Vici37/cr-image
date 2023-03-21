# Provides methods for histogram and histogram equalization. Follows method outlined [here](https://www.sci.utah.edu/~acoste/uou/Image/project1/Arthur_COSTE_Project_1_report.html)
#
# If an image is particularly dark or particularly bright with low contrast, the `Operation::Contrast#contrast` method will only
# make the image darker or lighter. For images like these, equalizing the image along its histogram will produce better results.
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mt_fuji.jpg" alt="A dark image of Mt. Fuji"/>
#
# ```
# image.contrast(10).save("contrast.jpg")
# image.histogram_equalize_image.save("equalized.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mt_fuji_contrast_10.jpg" alt="Darker image of Mt. Fuji"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mt_fuji_histogram_equalized.jpg" alt="A higher contrast image of Mt. Fuji"/>
#
# This method does not work well when a given method has a bimodal distribution of color pixels. For example:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample_equalized.jpg" alt="Highly pixelated and poor quality photo of woman in black turtleneck on white background in grayscale"/>
module CrImage::Operation::Histogram
  def histogram(channel_type : ChannelType) : Hash(UInt8, Int32)
    ret = Hash(UInt8, Int32).new { |h, k| h[k] = 0 }

    self[channel_type].each do |pixel|
      ret[pixel] += 1
    end

    ret.map(&.itself).sort!.to_h
  end

  def normalized_histogram(channel_type : ChannelType) : Hash(UInt8, Float64)
    histogram(channel_type).map do |pixel, count|
      {pixel, count.to_f / size}
    end.to_h
  end

  def cumulative_distribution_histogram(channel_type : ChannelType) : Hash(UInt8, Float64)
    total = 0f64
    normalized_histogram(channel_type).map do |pixel, probability|
      original = total
      total += probability
      {pixel, original}
    end.to_h
  end

  def histogram_equalize(channel_type : ChannelType) : Hash(UInt8, UInt8)
    cumulative_distribution_histogram(channel_type).map do |pixel, cumalative|
      {pixel, (cumalative * 255).clamp(0, 255).to_u8}
    end.to_h
  end

  def histogram_equalize_image : self
    clone.histogram_equalize_image!
  end

  def histogram_equalize_image! : self
    each_channel do |channel, channel_type|
      next if channel_type.alpha?
      remap = histogram_equalize(channel_type)
      size.times do |i|
        channel.unsafe_put(i, remap[channel.unsafe_fetch(i)])
      end
    end
    self
  end

  def draw_histogram(channel_type : ChannelType) : RGBAImage
    hist = normalized_histogram(channel_type)
    probabilities = hist.values
    max_prob = probabilities.max
    mult = 100 / max_prob

    w = 100 + 40
    h = 255 + 40

    init = Array(UInt8).new(w * h) { 255u8 }
    rgba = RGBAImage.new(init.clone, init.clone, init.clone, init.clone, w, h)
    rgba.draw_square!(19, 19, 101, 256, Color.of("#f00"))
    0.upto(255).each do |i|
      line_length = (hist[i]? || 0) * mult
      rgba.draw_square!(20, i + 20, line_length.to_i, 1, Color.of("#00f"))
    end

    rgba
  end
end
