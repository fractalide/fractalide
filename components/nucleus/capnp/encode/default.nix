{ stdenv, buildFractalideComponent, genName, upkeepers, capnproto
  , generic_text
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text path ];
  depsSha256 = "10n4yqfj9sk9vgf6vsqjd3456hqqgcymqbf0qmb19b82w0j0sxxm";
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
