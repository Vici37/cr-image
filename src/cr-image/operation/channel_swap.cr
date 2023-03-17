# Swaps channels of `ChannelType` supported by an image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.channel_swap(:green, :red) # Crystal autocasting of symbols to Pluto::ChannelType enum is magic
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/channel_swapped_green_red_sample.jpg" alt="Channel swapped image swapping the green and red channels"/>
module CrImage::Operation::ChannelSwap
  def channel_swap(a : ChannelType, b : ChannelType) : self
    clone.channel_swap!(a, b)
  end

  def channel_swap!(a : ChannelType, b : ChannelType) : self
    ch_a, ch_b = self[a], self[b]
    self[a] = ch_b
    self[b] = ch_a
    self
  end
end
