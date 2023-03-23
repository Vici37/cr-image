require "./cr-image"
require "./lib-formats/jpeg"

CrImage::Image.subsclasses_include(CrImage::Format::JPEG)
