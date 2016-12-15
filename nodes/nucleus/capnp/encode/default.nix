{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ generic_text path ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1zjydpf8ckz2iwmwll01gf23zjzqyq3dha2m2ryrm43djg7zv251";
  configurePhase = with pkgs; ''
    runHook preConfigure
    substituteInPlace src/lib.rs --replace "capnp_path" "${capnproto}/bin/capnp"
  '';
}
