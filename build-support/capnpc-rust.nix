{ stdenv, fetchFromGitHub, rustUnstable, makeWrapper, rustRegistry, buildRustPackage }:

with rustUnstable rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-2015-12-07";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "1123a4f5de32f0300f1a6b8014b6c3525e170fa9";
    sha256 = "08nq5m9z3jzhf5gr592ajln18dm5yvw1akk39l4cqi64afq81li3";
  };

  depsSha256 = "1lax0hl26x8fxvlq64spw9mzhykwlkq4xwhx62kj7dgm6c57fl6l";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
