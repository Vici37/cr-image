require "../src/pluto"
require "../src/stumpy"
require "stumpy_jpeg"

file_name = "./docs/images/sample.jpg"
st_i = StumpyJPEG.read(file_name)
cr_i = CrImage::RGBAImage.open("./sample.ppm")
pl_i = File.open(file_name) { |file| Pluto::ImageRGBA.from_jpeg(file) }

st_i.to_crimage.save("stumpy_sample.ppm")
cr_i.save("crimage_sample.ppm")
pl_i.to_crimage.save("pluto__sample.ppm")

cr_i.to_stumpy.to_crimage.save("crimage_stumpy_crimage_sample.ppm")
