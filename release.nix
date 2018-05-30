{ isTravis ? false
}:

with import <fractalide> {};

{
  inherit (pkgs) fractalide;
  fractalide-nixpkgs-unstable = let
    nixpkgs = import <nixpkgs>;
    fractapkgs = import ./pkgs { pkgs = nixpkgs; };
  in
    fractapkgs.fractalide;
} // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
  rs-tests = import ./tests;
} // pkgs.lib.optionalAttrs isTravis {
  travisOrder = [ "rs-tests" "fractalide" ];
}
