{ pkgs, support, edges, nodes, crates }:

let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "6b2036458b73d927799a6c57a41cc4e714fa9148";
    sha256 = "18raw44cn67f6dwl7b63y1m470y63vbr5h689c5z3nsakigv0ydc";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit pkgs support edges nodes crates; fractalide = null;}
