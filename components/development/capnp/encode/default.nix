{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, capnproto, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "path"];
  depsSha256 = "1r6wnih68bdhjhmi1f3swp7cwvpkfa3bbjf8pqk1j93y8z6xmsb3";
  configurePhase = ''
    runHook preConfigure
    substituteInPlace src/lib.rs --replace "capnp_path" "${capnproto}/bin/capnp"
  '';
  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/fvm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
