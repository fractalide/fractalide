{ fetchFromGitHub, crates, rustBinary }:

rustBinary {
  name = "capnpc-rust";
  binary = "bin";
  crates = with crates; [ capnp capnpc ];
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "4c305605484c6cf16716d5a6683b5dbcb1ad0fbd";
    sha256 = "06w19i59pjrpbbzhfmdsh2g8jzxh36vfykyhxypb4ycajbzk96iy";
  };
  depsSha256 = "07f11b2nanrv6mi460r9wq2mm3jk7nqawhxvsr81hrl4za9fdr26";
}
