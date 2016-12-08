{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0gvr58pk14xiflicp4q33gpdr762a5hfvdzzmr35jld4685cdj3w";
}
