{ stdenv, buildFractalideComponent, genName, upkeepers, capnproto
  , generic_text
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text path ];
  depsSha256 = "1q3spfr42xw777fxfjil17gpikjh3sb678djwf9j3ysdmhnj9vj0";
  configurePhase = ''
    runHook preConfigure
    substituteInPlace src/lib.rs --replace "capnp_path" "${capnproto}/bin/capnp"
  '';
  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
