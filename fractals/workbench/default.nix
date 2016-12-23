{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_workbench";
    rev = "f544eb59683e3589a7749b0fe38451de60b42af8";
    sha256 = "1998ldzvd4bs29xll0amiqmqx59rc6wpa8i84gj7i7gc8vi5fy0w";
  };
  /*fractal = ../../../fractals/fractal_workbench;*/
in
  import fractal {inherit buffet; fractalide = null;}
