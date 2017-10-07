{ pkgs }:
pkgs.haskellPackages.mkDerivation {
  pname = "idris";
  src = pkgs.fetchFromGitHub {
    owner = "idris-lang";
    repo = "Idris-dev";
    rev = "70f172c92ada0d57495ccbe477271d699ef7de85";
    sha256 = "1jm4lpy640n2m7p316hirn9wz6bpy36vkbn2glj1gn3n5m7hh1s2";
  };
  enableSharedExecutables = false;
  version = "1.1.0";
  isLibrary = true;
  isExecutable = true;
  doCheck = false;
  buildDepends = with pkgs.haskellPackages; [
    annotated-wl-pprint aeson ansi-terminal ansi-wl-pprint async base64-bytestring blaze-html blaze-markup cheapskate code-page fingertree
    fsnotify ieee754 mtl network optparse-applicative parsers regex-tdfa safe split tasty tasty-golden tasty-rerun terminal-size trifecta uniplate utf8-string vector-binary-instances zip-archive libffi
  ];
  buildTools = with pkgs.haskellPackages; [ happy ];
  extraLibraries = with pkgs; [ boehmgc gmp makeWrapper ];
  /*configureFlags = "-fgmp -fffi";*/
  /*postInstall =  with pkgs; ''
    ls -la $out/bin
    wrapProgram "$out/bin/idris" \
      --suffix NIX_CFLAGS_COMPILE : '"-I${gmp.dev}/include -L${gmp}/lib -L${boehmgc}/lib"' \
      --suffix PATH : ${stdenv.cc}/bin
  '';*/
  jailbreak = true;
  license = pkgs.stdenv.lib.licenses.bsd3;
}
