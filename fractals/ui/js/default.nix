{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_ui_js";
    rev = "dcf72aa94e13cbc2916bcfdc72137428f4adbcf2";
    sha256 = "00v0b47ldk81vzbry81qwby6wjkjzkwyfjkkd547n6ajh8plyj9h";
  };
  /*fractal = ../../../../fractals/fractal_ui_js;*/
in
  import fractal {inherit buffet; fractalide = null;}
