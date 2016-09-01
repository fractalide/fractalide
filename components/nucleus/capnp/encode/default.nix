{ stdenv, buildFractalideComponent, genName, upkeepers, capnproto
  , generic_text
  , path
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text path ];
  depsSha256 = "092m597k0h9dp7mb8x10ihawys2f4ba9x5v4lcj3yl97x4f0xjrd";
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
