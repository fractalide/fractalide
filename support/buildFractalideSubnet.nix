{ stdenv, genName, writeTextFile}:
{ src, subnet, name ? null, ... } @ args:
  let
  subnet-name = if name == null then genName src else name;
  subnet-txt = writeTextFile {
    name = subnet-name;
    text = subnet;
    executable = false;
  };
  in stdenv.mkCachedDerivation  (args // {
    name = subnet-name;
    unpackPhase = "true";
    installPhase = ''
    runHook preInstall
    #echo "SUBNET"
    mkdir -p $out/lib
    cp  ${subnet-txt} $out/lib/lib.subnet
    '';
  })
