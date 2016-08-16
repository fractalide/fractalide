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

  depsSha256 = "0f4qyvry70fvc6rwxgccxzvl2gggpg0qahij5l1pwq7p5w7gwgsg";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
