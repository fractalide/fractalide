{ stdenv, cacert, git, cargo, rustRegistry, rustcMaster }:
{ name ? "cargo-deps", src, srcs, sourceRoot, sha256, cargoUpdateHook ? "" }:

stdenv.mkDerivation {
  name = "${name}-fetch";
  buildInputs = [ cargo rustcMaster git ];
  inherit src srcs sourceRoot rustRegistry rustcMaster cargoUpdateHook;

  phases = "unpackPhase installPhase";

  installPhase = ''
    source ${./fetch-cargo-deps}
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    fetchCargoDeps . "$out"
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = sha256;

  impureEnvVars = [ "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy" ];
  preferLocalBuild = true;
}
