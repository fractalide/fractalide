{ stdenv, fetchFromGitHub, rustc, makeWrapper, rustRegistry, buildRustPackage }:

with rustc rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-v0.7.0";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "7f24c99322d1417f48555ebfcfb1da2449df880a";
    sha256 = "1zaf1gdwhvr8yl657s7zxnqam8679x3isqcjqgmzcxp829bm15fp";
  };

  depsSha256 = "1hy9ynkg0fr52y9qxy5fzqiscmw545jqqz4sy3mprcvx6nwr1mrl";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
