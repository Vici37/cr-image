module CrImageSampleHelper
  IMAGES = {
    "moon" => "scenic/moon",
  }

  macro included
    {% for name, location in IMAGES %}
      def gray_{{name.id}}_ppm
        CrImage::GrayscaleImage.open("lib/cr-image-samples/{{location.id}}.ppm")
      end

      def rgba_{{name.id}}_ppm
        CrImage::RGBAImage.open("lib/cr-image-samples/{{location.id}}.ppm")
      end

      def gray_{{name.id}}_jpg
        CrImage::GrayscaleImage.open("lib/cr-image-samples/{{location.id}}.jpg")
      end

      def rgba_{{name.id}}_jpg
        CrImage::RGBAImage.open("lib/cr-image-samples/{{location.id}}.jpg")
      end
    {% end %}
  end
end
