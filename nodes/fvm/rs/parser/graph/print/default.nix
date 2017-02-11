{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph ];
  crates = with mods.crates; [ rustfbp capnp ];
}
