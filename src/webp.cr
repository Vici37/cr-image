require "./cr-image"
require "./lib-formats/webp"

CrImage::Image.subsclasses_include(CrImage::Format::WebP)
