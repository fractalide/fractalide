{ stdenv, fetchFromGitHub, rustc, makeWrapper, rustRegistry, buildRustPackage }:

with rustc rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-v0.7.2";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "9d140f9aa23f34472a787d04f6eafacba8053c4f";
    sha256 = "1scfxgd9g4h51r84bg9iqkvbr55yzi87lilw9ash6chz20s7p6mf";
  };

  depsSha256 = "0bv41kygdsjyday889ggylxk2v2y4jn90v92hjpirgzdygd1i6gr";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
