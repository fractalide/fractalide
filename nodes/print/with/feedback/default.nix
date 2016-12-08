{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [ path value_string ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "01fgc8ys3m54rmm7kn67jlxasc8h4n2vz33qhvq30rfjv7k8ggr2";
}
