{ agent, edges, crates, pkgs }:

agent {
  src = ./.;
  edges = with edges; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0bifjw5kz8w77bnv3jqy54ynjlwagp56k5a5afmzwg9vayvapifv";
}
