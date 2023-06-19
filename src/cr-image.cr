require "complex"

# Things that will be included directly in `image` below
require "./cr-image/operation/*"
require "./cr-image/format/save"
require "./cr-image/format/open"

# Native crystal image format implementations
require "./cr-image/format/ppm"

# Require `image` first, and then subclasses of it
require "./cr-image/image"
require "./cr-image/grayscale_image"
require "./cr-image/rgba_image"

# Include anything else
require "./cr-image/**"
