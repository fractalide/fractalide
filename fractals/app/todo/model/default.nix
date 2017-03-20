{ buffet }:

let
  fractal = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_app_todo_model";
    rev = "8554f1ec5a87c33c478ab045a0fea85c76a7217c";
    sha256 = "0c39wnghilcjz0z9b7jnzl7zq69dk2ndcj3ikhh8nihxqhkhm3ci";
  };
  /*fractal = ../../../../../fractals/fractal_app_todo_model;*/
in
  import fractal {inherit buffet; fractalide = null;}
