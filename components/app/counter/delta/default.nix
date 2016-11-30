{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ app_counter generic_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "0yav2znjhqlqh6f17jn8sjdk7sf7wxjm5y6df8nxmgiv14x5ln1f";
}
