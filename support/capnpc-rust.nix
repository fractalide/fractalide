{ stdenv, fetchFromGitHub, rustc, makeWrapper, rustRegistry, buildRustPackage }:

with rustc rustRegistry;

buildRustPackage rec {
  name = "capnpc-rust-v0.7.3";
  src = fetchFromGitHub {
    owner = "fractalide";
    repo = "capnpc-rust";
    rev = "ddae2d35e94da9003ac862b12e36997f81cceb07";
    sha256 = "1ld2fz9sm0ggwv4d3c5fmch199paxgyfwjh350cgzmaiy11brdgy";
  };

  depsSha256 = "1rgbzialdk5j7yv2lqyvwk8bsvsbpwf2wwn3v82sv3mz2pnhakyq";

  meta = with stdenv.lib; {
    description = "Cap'n Proto code generation for Rust.";
    homepage = https://github.com/fractalide/capnpc-rust;
    license = with licenses; [ mit ];
    maintainers = [ maintainers.sjmackenzie ];
  };
}
