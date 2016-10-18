{ stdenv, buildFractalideComponent, genName, upkeepers, capnproto
  , generic_text
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text path ];
  depsSha256 = "0phvzqdvjakygdml0h2j2b07474j9aqhfdnsc3i6211srki7ydbw";
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
