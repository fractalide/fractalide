{ buffet }:

  let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "80eb2348b4a3798294c0a1f03a0a488577900e25";
    sha256 = "0vgns374554fr1bwylcsik05af51h1ck2a99z2i12brqiimjil1y";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
  in
    import fractal {inherit buffet; fractalide = null;}
