{ stdenv, fetchFromGitHub, rustUnstable, makeWrapper, rustRegistry, buildRustPackage }:

with rustUnstable rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-v0.7.0";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "511ffce2c45eae408adb7584a6b2ed73b3c58698";
    sha256 = "0rijf5b0wzvs0xvl2prqxasmpdcb219j62gjy1n8ffz9z07jhda1";
  };

  depsSha256 = "0irs0hy8ivhx2hyxrcy3pk9mrnmydzl2hmvfnqjilln5spds8l5p";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
