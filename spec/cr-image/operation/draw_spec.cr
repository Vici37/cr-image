require "../../spec_helper"

Spectator.describe CrImage::Operation::Draw do
  include SpecHelper

  alias Color = CrImage::Color

  specs_for_operator(draw_square(image.to_gray.threshold(8).region, Color.of("#00f")),
    gray_hash: "23be9687013d598d9416fa3cf428d699f5fe9572",
    rgba_hash: "1235b84c0debd42b71b5d20786386f7451928321"
  )

  specs_for_operator(draw_square!(image.to_gray.threshold(8).region, Color.of("#00f")),
    gray_hash: "23be9687013d598d9416fa3cf428d699f5fe9572",
    rgba_hash: "1235b84c0debd42b71b5d20786386f7451928321",
  )

  specs_for_operator(draw_square(20, 20, 100, 100, Color.of("#00f")),
    gray_hash: "1ed4dcb15c6bc97af31eb8dadd05717eea09c082",
    rgba_hash: "6aa0ca38d5e245291632f1d6f2861bad5e05d4be"
  )

  specs_for_operator(draw_square!(20, 20, 100, 100, Color.of("#00f")),
    gray_hash: "1ed4dcb15c6bc97af31eb8dadd05717eea09c082",
    rgba_hash: "6aa0ca38d5e245291632f1d6f2861bad5e05d4be",
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

  it "draws a line", :focus do
    puts "Drawing"
    rgba_moon_ppm.draw_line(100, 100, 200, 200, Color.of("#00f")).save("moon_with_line.jpg")
  end
end
