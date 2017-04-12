{ buffet }:

buffet.support.rs.executable {
  name = "capnpc-rust";
  mods = with buffet.mods.rs; [ capnp capnpc ];
  src = buffet.pkgs.fetchFromGitHub {
    owner = "dwrensha";
    repo = "capnpc-rust";
    rev = "421674174c599cc4a7d246006678468586d12f37";
    sha256 = "0q8dcjy74gblha2wy1hvzb9398gn3qb8kfxqdck6sav6f71rlb13";
  };
}
