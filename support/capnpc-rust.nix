{ fetchFromGitHub, crates, rustBinary }:

rustBinary {
  name = "capnpc-rust";
  binary = "bin";
  crates = with crates; [ capnp capnpc ];
  src = fetchFromGitHub {
    owner = "dwrensha";
    repo = "capnpc-rust";
    rev = "e662a3cf50eecebeadfd1f0c4755cf779840b93b";
    sha256 = "03khbs6cg38z41i53v3l9h45sr6nvvki7q7v04h1lmc0l3yhgc5w";
  };
}
