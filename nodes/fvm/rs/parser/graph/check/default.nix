{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph CoreSemanticError ];
  crates = with mods.crates; [ rustfbp capnp ];
}
