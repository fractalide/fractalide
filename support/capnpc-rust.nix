{ stdenv, fetchFromGitHub, rustc, makeWrapper, rustRegistry, buildRustPackage }:

with rustc rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-v0.7.0";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "de38049b5ec7342dc27a3ed388ecc6c2dda032a5";
    sha256 = "185jmjxc6fzidjcidcryc6dw5vlbsv5yr4azhlz4nzpp241hn53m";
  };

  depsSha256 = "10zqi7w5v2xpydxy2nqqr9j9n9w29k6fzfx3wy1qd3sk1wh3jglx";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
