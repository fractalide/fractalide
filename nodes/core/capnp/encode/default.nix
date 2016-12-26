{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ prim_text fs_path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  configurePhase = with pkgs; ''
    runHook preConfigure
    substituteInPlace lib.rs --replace "capnp_path" "${capnproto}/bin/capnp"
  '';
}
