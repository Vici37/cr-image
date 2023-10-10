require "../../spec_helper"

Spectator.describe CrImage::Operation::Draw do
  include SpecHelper

  alias Color = CrImage::Color

  specs_for_operator(draw_square(image.to_gray.threshold(8).region, Color.of("#00f")),
    gray_hash: "4d8323c4cfce2cae736185b0b714252ac4547f79",
    rgba_hash: "ba0d7b953555121c252843f3db01d0a1c2c9dd89"
  )

  specs_for_operator(draw_square!(image.to_gray.threshold(8).region, Color.of("#00f")),
    gray_hash: "4d8323c4cfce2cae736185b0b714252ac4547f79",
    rgba_hash: "ba0d7b953555121c252843f3db01d0a1c2c9dd89",
  )

  specs_for_operator(draw_square(20, 20, 100, 100, Color.of("#00f")),
    gray_hash: "48acaf112aa49d6b7d8073b37883f03fb4c2b2e5",
    rgba_hash: "ad5686a6597cdf660077d9457ddd6b3a1733a2b3"
  )

  specs_for_operator(draw_square!(20, 20, 100, 100, Color.of("#00f")),
    gray_hash: "48acaf112aa49d6b7d8073b37883f03fb4c2b2e5",
    rgba_hash: "ad5686a6597cdf660077d9457ddd6b3a1733a2b3",
  )

  specs_for_operator(draw_square(20, 20, 100, 100, Color.of("#0f0"), fill: true),
    gray_hash: "11ab326f0709f623df7f79eaaedb04d79e90022c",
    rgba_hash: "a61e87d3e33ecf0f8bb6c559e7bf6a573f63d1e0"
  )

  specs_for_operator(draw_circle(20, 20, 20, Color.of("#00f")),
    gray_hash: "8a46cf3cddc5772db989368dd4303ec92708859a",
    rgba_hash: "c702a0dc0c1c5439fd2f5688c864a088eeb422b5",
  )

  specs_for_operator(draw_circle(-10, -10, 20, Color.of("#00f")),
    gray_hash: "dd7b8900f3be9108ebb8f9e8b4729e85e203f04c",
    rgba_hash: "def9f0e3d6138f5b94ee0821a3d06f1436e72b38",
  )

  specs_for_operator(draw_circle(image.width - 1, image.height - 1, 20, Color.of("#00f")),
    gray_hash: "a1867b870561d12801d03211efc8c851f0f01893",
    rgba_hash: "d4d7040502e92143698da5d9126df9120cb45f98",
  )

  specs_for_operator(draw_circle(20, 20, 20, Color.of("#00f"), fill: true),
    gray_hash: "08703a13126ee22d7ca3b8d9098a4f00de108576",
    rgba_hash: "f0c527e5e9222a5e18a6be7ddb9f2b34f03cf9af"
  )

  specs_for_operator(draw_circle(-10, -10, 20, Color.of("#00f"), fill: true),
    gray_hash: "a45497e5fb8454961b580c613bc1f1361507d4f8",
    rgba_hash: "5bb275fb9fce022de8dd511fa250c864bdad6423"
  )

  specs_for_operator(draw_circle(image.width - 1, image.height - 1, 20, Color.of("#00f"), fill: true),
    gray_hash: "a549a00b8e2a5bc42bd53df577ae92d58ee573a5",
    rgba_hash: "22e57ead344f2fe90e6a4ed7d0807822f035a3c7"
  )

  specs_for_operator(draw_line(0, 0, image.width - 1, image.height - 1, Color.of("#f")),
    gray_hash: "21e66ec056a382633d3c4158d70d61191309dc75",
    rgba_hash: "2abcbd00bedb20c0aeff5c0c25cb2100817f1299"
  )

  specs_for_operator(draw_line(100, 100, 100, 200, Color.of("#f")),
    gray_hash: "b2f46f6bcd4391703e07c35607604aba9e881b1b",
    rgba_hash: "8fc01dfd506c1b14c348d6d39357d782d524478d"
  )

  specs_for_operator(draw_line(100, 100, 200, 100, Color.of("#f")),
    gray_hash: "90c46c6817c59dc027a58257722aaea549590629",
    rgba_hash: "da5361b9db4d95e045463f854e0cf51701c4dc0a"
  )

  specs_for_operator(draw_line(100, 100, 200, 110, Color.of("#f")),
    gray_hash: "5f4806022bc984525256bb3985d76b533a4c912b",
    rgba_hash: "b3c2785f1bb51da14ca08f4f5ef12282f156fa9d"
  )

  context "checks bounds" do
    let(image) { gray_moon_ppm }
    it "throws if first point is outside of image" do
      expect_raises(CrImage::Exception, /First point/) { image.draw_line!(-1, -1, 0, 0, Color.random) }
    end

    it "throws if second point is outside of image" do
      expect_raises(CrImage::Exception, /Second point/) { image.draw_line!(0, 0, 1000, 0, Color.random) }
    end
  end
end
