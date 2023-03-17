# Applies a 3x3 Gaussian blur
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.gaussian_blur(1).save("gaussian_1_sample.jpg")
# image.gaussian_blur(5).save("gaussian_5_sample.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gaussian_1_sample.jpg" alt="Blurred sample image with value 1"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gaussian_5_sample.jpg" alt="Blurred sample image with value 5"/>
module CrImage::Operation::GaussianBlur
  def gaussian_blur(sigma : Int32) : self
    clone.gaussian_blur!(sigma)
  end

  def gaussian_blur!(sigma : Int32) : self
    n = 3

    w_ideal = Math.sqrt((12 * sigma * sigma / n) + 1)
    w_l = w_ideal.floor.to_i
    w_l -= 1 if w_l % 2 == 0

    m_ideal = (12 * sigma * sigma - n * w_l * w_l - 4 * n * w_l - 3 * n) / (-4 * w_l - 4)
    m = m_ideal.round

    sizes = [] of Int32
    n.times do |i|
      sizes << if i < m
        w_l
      else
        w_l + 2
      end
    end

    box_blur!((sizes.unsafe_fetch(0) - 1) // 2)
    box_blur!((sizes.unsafe_fetch(1) - 1) // 2)
    box_blur!((sizes.unsafe_fetch(2) - 1) // 2)

    self
  end
end
