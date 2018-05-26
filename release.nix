with import <fractalide> {};

{
  inherit (pkgs) fractalide;
  fractalide-nixpkgs-unstable = let
    nixpkgs = import <nixpkgs>;
    fractapkgs = import ./pkgs { pkgs = nixpkgs; };
  in
    fractapkgs.fractalide;
}
