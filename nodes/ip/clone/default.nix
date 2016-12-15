{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1gbyk0c7y6h39ra77fzz5d002j7kzyvy218fsn6rr9sqw6bwp63j";
}
