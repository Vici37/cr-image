require "../../spec_helper"

Spectator.describe CrImage::Operation::Draw do
  include SpecHelper

  alias Color = CrImage::Color

  specs_for_operator(draw_box(image.to_gray.threshold(8).region, Color.of("#00f")),
    gray_hash: "23be9687013d598d9416fa3cf428d699f5fe9572",
    rgba_hash: "1235b84c0debd42b71b5d20786386f7451928321"
  )

  specs_for_operator(draw_box!(image.to_gray.threshold(8).region, Color.of("#00f")),
    gray_hash: "23be9687013d598d9416fa3cf428d699f5fe9572",
    rgba_hash: "1235b84c0debd42b71b5d20786386f7451928321",
  )

  specs_for_operator(draw_box(20, 20, 100, 100, Color.of("#00f")),
    gray_hash: "1ed4dcb15c6bc97af31eb8dadd05717eea09c082",
    rgba_hash: "6aa0ca38d5e245291632f1d6f2861bad5e05d4be"
  )

  specs_for_operator(draw_box!(20, 20, 100, 100, Color.of("#00f")),
    gray_hash: "1ed4dcb15c6bc97af31eb8dadd05717eea09c082",
    rgba_hash: "6aa0ca38d5e245291632f1d6f2861bad5e05d4be",
  )

  specs_for_operator(draw_box(20, 20, 100, 100, Color.of("#0f0"), fill: true),
    gray_hash: "11ab326f0709f623df7f79eaaedb04d79e90022c",
    rgba_hash: "a61e87d3e33ecf0f8bb6c559e7bf6a573f63d1e0"
  )
end
