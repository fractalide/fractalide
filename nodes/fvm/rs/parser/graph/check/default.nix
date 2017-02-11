{ rs, edges, mods }:

rs.agent {
  src = ./.;
  edges = with edges; [ CoreGraph CoreSemanticError ];
  mods = with mods.rs; [ rustfbp capnp ];
}
