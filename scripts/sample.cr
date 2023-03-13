require "../src/cr-image"

image = CrImage::RGBAImage.open("docs/images/moon.jpg")

# create a mask identifying all pixels with light (i.e. the moon)
moon_mask = image
  .to_gray
  .threshold(8) # pixels ar UInt8, so 0 is blank, 255 is white

# Crop out the moon from the image, and save it to a new file
image.crop(moon_mask.region).save("docs/images/moon_cropped.jpg")
