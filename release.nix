with import ./. {};

{
  inherit (pkgs) fractalide;
  fractalide-nixpkgs-unstable = let
    nixpkgs = import ../nixpkgs;
    fractapkgs = import ./pkgs { pkgs = nixpkgs; };
  in
    fractapkgs.fractalide;
}
