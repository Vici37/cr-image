require "../../spec_helper"

Spectator.describe CrImage::Operation::Rotate do
  include SpecHelper

  specs_for_operator(rotate(45),
    gray_hash: "b23e83666e8046bd28396b3c5d7e4c7874671cfd",
    rgba_hash: "e21797526425cd7e9473ca479f45bbdb8e049d1e"
  )

  specs_for_operator(rotate(90),
    gray_hash: "124795c3ed7e003750d024f610626c3b22b26206",
    rgba_hash: "fd20c71bb52ff5a148dfcea9f4fe49ab92c80804"
  )

  specs_for_operator(rotate(-30),
    gray_hash: "a14c40f3c480330e4ec8aa9d8441d3e08d6e3864",
    rgba_hash: "edafe8f2472918dcdad5e72187665fcc32e14851"
  )

  specs_for_operator(rotate(45, center_x: 100, center_y: 200),
    gray_hash: "89f91776edc2c8814d235c29d0a50eaa3f015753",
    rgba_hash: "fb4a52471956cd6a48aee2f4470477a4b295587c"
  )

  specs_for_operator(rotate(45, center_x: 375, center_y: 250, radius: 20),
    gray_hash: "171f3aa256a46a3aeec94cddec477ed01fdb658e",
    rgba_hash: "ba9d444ed5f4567830d6037990231aae0f3431ca"
  )

  specs_for_operator(rotate(45, pad: true),
    gray_hash: "7c2fcb8541211f4cfd4f8d9a51a638233a16dfb7",
    rgba_hash: "21cf483faed9e7333801b78e9c4b4bc373a4ada9"
  )

  specs_for_operator(rotate(45, pad: true, edge_policy: CrImage::EdgePolicy::Repeat),
    gray_hash: "7c2fcb8541211f4cfd4f8d9a51a638233a16dfb7",
    rgba_hash: "90103263037ed12b1fc39554307ee8c49eafcbe1"
  )
end
