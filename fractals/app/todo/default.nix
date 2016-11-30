{ pkgs, support, contracts, components, crates }:

  let
  fractal = pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo";
    rev = "abd1dea2ff207d870ae59f5bf113771fdc920852";
    sha256 = "1ylf7z01c3ps381ggrvdczgz4kkcm7ay0vm3irmvvcngvwpb3hx9";
  };
  /*fractal = ../../../../fractals/fractal_app_todo;*/
  in
  import fractal {inherit pkgs support contracts components crates; fractalide = null;}
