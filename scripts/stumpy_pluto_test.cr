require "../src/pluto"
require "../src/stumpy"
require "stumpy_png"

file_name = "./lib/cr-image-samples/scenic/moon.png"
st_i = StumpyPNG.read(file_name)
cr_i = CrImage::RGBAImage.open("./lib/cr-image-samples/scenic/moon.ppm")
pl_i = File.open(file_name) { |file| Pluto::ImageRGBA.from_png(file) }

st_i.to_crimage.save("stumpy_crimage_sample.ppm")
cr_i.save("crimage_sample.ppm")
pl_i.to_crimage.save("pluto_crimage_sample.ppm")

StumpyPNG.write(cr_i.to_stumpy, "crimage_stumpy_sample.png")
pl_i = File.open("crimage_stumpy_sample.png") { |file| Pluto::ImageRGBA.from_png(file) }
pl_i.to_crimage.save("crimage_stumpy_pluto_sample.ppm")
