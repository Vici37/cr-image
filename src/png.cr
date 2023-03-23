require "./cr-image"
require "./lib-formats/png"

CrImage::Image.subsclasses_include(CrImage::Format::PNG)
