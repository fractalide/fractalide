{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ maths_number ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "028xyjzfbiz7mxhdmwb55dg5npr1flwhbjkzsrlj4f92cq8n7vr7";
}
