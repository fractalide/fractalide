{ stdenv, fetchFromGitHub, rustc, makeWrapper, rustRegistry, buildRustPackage }:

with rustc rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-v0.7.0";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "f096d38668512b1ce84e306b227e91a2ede174fe";
    sha256 = "1ksfhwl695441wgcmpsgl3rmqpaf8d7yv53a9pjyjj3312kbjh7x";
  };

  depsSha256 = "10i91ljqsy70l57ccgffiq9nf42kcvjg1gy1pc7scjj2r66maha6";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
