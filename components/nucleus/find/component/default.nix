{ component, contracts, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ path option_path ];
  depsSha256 = "1q6s9b1ay8dam9wnrpdzny7gd0lava27b7brnijn6hyb8a3173rq";
  buildInputs = with pkgs; [ nix ];
}
