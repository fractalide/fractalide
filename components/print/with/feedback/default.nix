{ component, contracts, crates, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ path value_string ];
  crates = with crates; [];
  osdeps = with pkgs; [];
  depsSha256 = "01fgc8ys3m54rmm7kn67jlxasc8h4n2vz33qhvq30rfjv7k8ggr2";
}
