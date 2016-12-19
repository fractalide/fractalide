{ crate, crates }:

crate {
  name = "rustfbp";
  crates = with crates; [ capnp libloading threadpool ];
  src = ./rustfbp;
}
