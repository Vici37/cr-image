# Utility class for Fast Fourier Transforms
class CrImage::FftUtil
  def self.fft2d(width : Int32, inp : Array(Float64), buffer : Array(Complex)?) : Array(Complex)
    unless buf = buffer
      buf = Array(Complex).new(Math.max(map.width, map.height)) { Complex.zero }
    end
    FftUtil.fft1d_unsafe(width, inp.dup, buf)
  end

  def self.fft2d_unsafe(width : Int32, ret : Array(Complex), buffer : Array(Complex)) : Array(Complex)
    row_buffer = Array(Complex).new(width) { Complex.zero }
    height = ret.size // width
    height_buffer = Array(Complex).new(height) { Complex.zero }

    beginning = -width
    height.times do
      beginning += width
      row_buffer.to_unsafe.copy_from(ret.to_unsafe + beginning, width)
      FftUtil.fft1d_unsafe(row_buffer, buffer)
      (ret.to_unsafe + beginning).copy_from(row_buffer.to_unsafe, width)
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

  def self.fft1d(inp : Array(Float64), buffer : Array(Complex)?) : Array(Complex)
    unless buf = buffer
      buf = Array(Complex).new { Complex.zero }
    end
    FftUtil.fft1d(Array(Complex).new(inp.size) { |i| Complex.new(inp[i]) }, buf)
  end

  def self.fft1d(inp : Array(Complex), buffer : Array(Complex) = inp.dup) : Array(Complex)
    FftUtil.fft1d_unsafe(inp.dup, buffer)
  end

  # Calculates Fast Fourier Transform of `ret`. Uses and modifies `ret` in place.
  def self.fft1d_unsafe(ret : Array(Complex), buffer : Array(Complex) = ret.dup) : Array(Complex)
    # TODO: ensure `ret` size is a power of 2

    shape = 1
    half = ret.size
    real_half = ret.size // 2

    while half > 1
      double_half = half
      half //= 2
      neg_i_pi_div_shape = -Math::PI.i / shape
      buffer.to_unsafe.copy_from(ret.to_unsafe, ret.size)

      half_offset = 0
      shape.times do |i|
        term = Math.exp(neg_i_pi_div_shape * i)
        half.times do |j|
          offset = half + j + (half_offset)
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

      shape *= 2
    end

    ret
  end
end
