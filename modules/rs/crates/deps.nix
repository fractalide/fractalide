with import <nixpkgs> {};
  let
  fractalide = import <fractalide> {};
in
runCommand "dummy" { buildInputs = with fractalide.pkgs.rust; [ cargo ]; } ""
