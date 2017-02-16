{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith (buffet.pkgs);
  nix-purescript-index = buffet.pkgs.fetchFromGitHub {
    owner = "fractalide";
    repo = "nix-purescript-index";
    rev = "fe88050993d487240a4ce07e539168738a2feb90";
    sha256 = "0a9kp6wlig7mzq7bbfr9yqz8jlqf6xzkw2lqnxnj086llyrj9xbp";
  };
in
  buffet.pkgs.recurseIntoAttrs (callPackage nix-purescript-index {})
