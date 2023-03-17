# Blurs the image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.box_blur(1).save("blurred_1_sample.jpg")
# image.box_blur(5).save("blurred_5_sample.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/blurred_1_sample.jpg" alt="Blurred sample image with value 1"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/blurred_5_sample.jpg" alt="Blurred sample image with value 5"/>
module CrImage::Operation::BoxBlur
  def box_blur(value : Int32) : self
    clone.box_blur!(value)
  end

  def box_blur!(value : Int32) : self
    horizontal_blur!(value)
    vertical_blur!(value)
  end
end
