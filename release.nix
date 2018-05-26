with import ./. {};

{
  inherit (pkgs) fractalide;
  fractalide-nixpkgs-unstable = let
    nixpkgs = import ../nixpkgs;
    pkgs = import pkgs { pkgs = nixpkgs; };
  in
    inherit (pkgs) fractalide;
}
