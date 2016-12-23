{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_net_ndn";
    rev = "f003ff3659c60dafcd2ceb985381a3b4a163deb6";
    sha256 = "1mhlwk84lb0mchn7y77i8sj80swilg46i4hgpkm0vrzm5hfd99kl";
  };
  /*fractal = ../../../../fractals/fractal_net_ndn;*/
in
  import fractal {inherit buffet; fractalide = null;}
