{ crate, crates }:

crate {
  name = "rustfbp";
  mods = with crates; [ capnp libloading threadpool ];
  src = ./.;
}
