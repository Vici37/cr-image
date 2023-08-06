# Utility class for Fast Fourier Transforms
#
# At some point in the future, this may be moved to its own shard.
class CrImage::FftUtil
  # ============================================== FFT ==============================================

  # Perform Fast Fourier Transform, treating as `inp` as a 2 dimensional array with `width`.
  #
  # Can optionally pass in `buffer` which must be an array at least the larger of `width` or `inp.size // width`.
  def self.fft2d(width : Int32, inp : Array(Float64), buffer : Array(Complex)? = nil) : Array(Complex)
    FftUtil.fft2d(width, inp.map(&.to_c), buffer)
  end

  # :ditto:
  def self.fft2d(width : Int32, inp : Array(Complex), buffer : Array(Complex)? = nil) : Array(Complex)
    raise Exception.new "Width #{width} must be power of 2 (next power of two: #{width.next_power_of_two})" unless width == width.next_power_of_two
    height = inp.size // width
    raise Exception.new "Input height #{height} must be power of 2 (next power of two: #{(height).next_power_of_two})" unless height == height.next_power_of_two

    unless buf = buffer
      buf = Array(Complex).new(Math.max(width, inp.size // width)) { Complex.zero }
    end
    FftUtil.fft2d_unsafe(width, inp.dup, buf)
  end

  # Perform Fast Fourier Transform, using and rewriting `ret` for the output, as a 2 dimensional array with `width`. `buffer` must be an array
  # of length at least the longer of `width` or `height` of the input array.
  def self.fft2d_unsafe(width : Int32, ret : Array(Complex), buffer : Array(Complex)) : Array(Complex)
    height = ret.size // width
    height_buffer = Array(Complex).new(height) { Complex.zero }

    beginning = -width
    height.times do
      beginning += width
      slice = Slice(Complex).new(ret.to_unsafe + beginning, width)
      FftUtil.fft1d_unsafe(slice, buffer)
    end

    width.times do |x|
      spot = 0
      height.times do |i|
        height_buffer.unsafe_put(i, ret.unsafe_fetch(spot + x))
        spot += width
      end
      FftUtil.fft1d_unsafe(height_buffer, buffer)
      spot = 0
      height.times do |i|
        ret.unsafe_put(spot + x, height_buffer.unsafe_fetch(i))
        spot += width
      end
    end

    ret
  end

  # Perform Fast Fourier Transform on `inp`.
  #
  # Can optionally pass in `buffer` which must be the same length as `inp`
  def self.fft1d(inp : Array(Float64), buffer : Array(Complex)? = nil) : Array(Complex)
    # TODO: implement an even faster real-to-complex version of FFT: https://kovleventer.com/blog/fft_real/#:~:text=Fourier%20transforms%20are%20used%20to,will%20consist%20of%20real%20numbers
    unless buf = buffer
      buf = Array(Complex).new(inp.size) { Complex.zero }
    end
    FftUtil.fft1d(Array(Complex).new(inp.size) { |i| Complex.new(inp.unsafe_fetch(i)) }, buf)
  end

  # :ditto:
  def self.fft1d(inp : Array(Complex), buffer : Array(Complex) = inp.dup) : Array(Complex)
    raise Exception.new "Input is of size #{inp.size}, which is not a power of 2 (next power of 2: #{inp.size.next_power_of_two})" unless inp.size == inp.size.next_power_of_two
    FftUtil.fft1d_unsafe(inp.dup, buffer)
  end

  # Calculates Fast Fourier Transform of `ret`. Uses and modifies `ret` in place.
  #
  # Can optionally pass in `buffer` which must be the same length as `inp`. This method makes no bound checks or error checks.
  def self.fft1d_unsafe(ret : Array(Complex) | Slice(Complex), buffer : Array(Complex) | Slice(Complex) = ret.dup) : Array(Complex) | Slice(Complex)
    shape = 1
    half = ret.size
    real_half = (ret.size >> 1)

    while half > 1
      double_half = half
      half >>= 1
      neg_i_pi_div_shape = -Math::PI.i / shape
      buffer.to_unsafe.copy_from(ret.to_unsafe, ret.size)

      half_offset = half
      shape.times do |i|
        term = Math.exp(neg_i_pi_div_shape * i)
        half.times do |j|
          offset = j + half_offset
          buffer.unsafe_put(offset, buffer.unsafe_fetch(offset) * term)
        end
        half_offset += double_half
      end

      offset = -1
      counter = -1
      real_half.times do |i|
        offset += 1
        counter += 1
        if counter == half
          counter = 0
          offset += half
        end

        ret.unsafe_put(i,
          buffer.unsafe_fetch(offset) + buffer.unsafe_fetch(offset + half))
        ret.unsafe_put(i + real_half,
          buffer.unsafe_fetch(offset) - buffer.unsafe_fetch(offset + half))
      end

      shape <<= 1
    end

    ret
  end

  # ============================================== IFFT ==============================================

  # Perform Inverse Fast Fourier Transform, treating as `inp` as a 2 dimensional array with `width`.
  #
  # Can optionally pass in `buffer` which must be an array at least the larger of `width` or `inp.size // width`.
  def self.ifft2d(width : Int32, inp : Array(Complex), buffer : Array(Complex)? = nil) : Array(Complex)
    raise Exception.new "Width #{width} must be power of 2 (next power of two: #{width.next_power_of_two})" unless width == width.next_power_of_two
    height = inp.size // width
    raise Exception.new "Input height #{height} must be power of 2 (next power of two: #{(height).next_power_of_two})" unless height == height.next_power_of_two

    unless buf = buffer
      buf = Array(Complex).new(Math.max(width, inp.size // width)) { Complex.zero }
    end
    FftUtil.ifft2d_unsafe(width, inp.dup, buf)
  end

  def self.ifft2d_unsafe(width : Int32, ret : Array(Complex), buffer : Array(Complex)) : Array(Complex)
    height = ret.size // width
    height_buffer = Array(Complex).new(height) { Complex.zero }

    beginning = -width
    height.times do
      beginning += width
      slice = Slice(Complex).new(ret.to_unsafe + beginning, width)
      FftUtil.ifft1d_unsafe(slice, buffer)
    end

    width.times do |x|
      spot = 0
      height.times do |i|
        height_buffer.unsafe_put(i, ret.unsafe_fetch(spot + x))
        spot += width
      end
      FftUtil.ifft1d_unsafe(height_buffer, buffer)
      spot = 0
      height.times do |i|
        ret.unsafe_put(spot + x, height_buffer.unsafe_fetch(i))
        spot += width
      end
    end
    ret
  end

  # Perform Inverse Fast Fourier Transform on `inp`.
  #
  # Can optionally pass in `buffer` which must be at least the same size of `inp`.
  def self.ifft1d(inp : Array(Complex), buffer : Array(Complex) = inp.dup) : Array(Complex)
    raise Exception.new "Input is of size #{inp.size}, which is not a power of 2 (next power of 2: #{inp.size.next_power_of_two})" unless inp.size == inp.size.next_power_of_two
    FftUtil.ifft1d_unsafe(inp.dup, buffer)
  end

  # Perform Inverse Fast Fourier Transform on `ret`. Will use and overwrite the original values in `ret` to do so.
  #
  # Can optionally pass in `buffer` which must be at least the same size of `inp`. This method makes no bound checks or error checks.
  def self.ifft1d_unsafe(ret : Array(Complex) | Slice(Complex), buffer : Array(Complex) = ret.dup) : Array(Complex) | Slice(Complex)
    shape = 1
    half = ret.size
    real_half = (ret.size >> 1)

    while half > 1
      double_half = half
      half >>= 1
      neg_i_pi_div_shape = Math::PI.i / shape
      buffer.to_unsafe.copy_from(ret.to_unsafe, ret.size)

      half_offset = half
      shape.times do |i|
        term = Math.exp(neg_i_pi_div_shape * i)
        half.times do |j|
          offset = j + half_offset
          buffer.unsafe_put(offset, buffer.unsafe_fetch(offset) * term)
        end
        half_offset += double_half
      end

      offset = -1
      counter = -1
      real_half.times do |i|
        offset += 1
        counter += 1
        if counter == half
          counter = 0
          offset += half
        end

        ret.unsafe_put(i,
          buffer.unsafe_fetch(offset) + buffer.unsafe_fetch(offset + half))
        ret.unsafe_put(i + real_half,
          buffer.unsafe_fetch(offset) - buffer.unsafe_fetch(offset + half))
      end

      shape <<= 1
    end
    ret.map!(&./(ret.size))
  end
end
