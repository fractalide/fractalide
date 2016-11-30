{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0bifjw5kz8w77bnv3jqy54ynjlwagp56k5a5afmzwg9vayvapifv";
}
