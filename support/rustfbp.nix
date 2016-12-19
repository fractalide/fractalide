{ crate, crates, cratesDeps }:
let
  deps = with crates; [ capnp libloading threadpool ];
in
crate {
  name = "rustfbp";
  crates = deps;
  cratesDeps  = cratesDeps deps deps;
  src = ./rustfbp;
}
