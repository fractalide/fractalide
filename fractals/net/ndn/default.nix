{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "47856217069892f0205fa768950c90e27e7285a2";
    sha256 = "0ir4i7cxh9pipp9790s4fjchacg55k6695nxy73gi4gn9g1gs2sy";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
