{ pkgs
  , support
  , contracts
  , components
  , fetchFromGitHub
  , ...}:
let
  fractal = fetchFromGitHub {
    owner = "fractalide";
    repo = "fractal_nanomsg";
    rev = "4b3cdb53e62b7ad3aadf3a325335571096043aa2";
    sha256 = "1vdxga7y9chl53ba63gdawd2qgzzrs9g7va7x8lvsz9flj7ss4vk";
  };
  /*
  fractal = ../../../fractals/fractal_nanomsg;
  */
in
  import fractal {inherit pkgs support contracts components; fractalide = null;}
