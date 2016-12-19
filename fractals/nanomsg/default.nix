{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "d0c0dfbfd99a3588587ea91aca3fe78d4f82f012";
    sha256 = "18raw44cn67f6dwl7b63y1m470y63vbr5h689c5z3nsakigv0ydc";
  };
  /*fractal = ../../../fractals/fractal_nanomsg;*/
in
  import fractal {inherit buffet; fractalide = null;}
