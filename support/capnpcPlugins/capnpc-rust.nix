{ buffet }:

buffet.support.rs.executable {
  name = "capnpc-rust";
  crates = with buffet.mods.crates; [ capnp capnpc ];
  src = buffet.pkgs.fetchFromGitHub {
    owner = "dwrensha";
    repo = "capnpc-rust";
    rev = "e662a3cf50eecebeadfd1f0c4755cf779840b93b";
    sha256 = "03khbs6cg38z41i53v3l9h45sr6nvvki7q7v04h1lmc0l3yhgc5w";
  };
}
