{ stdenv, genName, writeTextFile}:
{ src, subnet,... } @ args:
  let
  name = genName src;
  subnet-txt = writeTextFile {
    name = name;
    text = subnet;
    executable = false;
  };
  in stdenv.mkDerivation  (args // {
    name = name;
    unpackPhase = "true";
    installPhase = ''
    mkdir -p $out/lib
    cp  ${subnet-txt} $out/lib/lib.subnet'';
  })
