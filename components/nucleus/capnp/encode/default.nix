{ component, contracts, pkgs }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text path ];
  depsSha256 = "0ahwp016qkfp2lmf9452hrhbb4zmlh9k1wz2aw3wi12qkhh0swsp";
  configurePhase = with pkgs; ''
    runHook preConfigure
    substituteInPlace src/lib.rs --replace "capnp_path" "${capnproto}/bin/capnp"
  '';
}
