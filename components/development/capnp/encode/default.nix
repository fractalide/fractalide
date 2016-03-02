{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, capnproto, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "path"];
  depsSha256 = "0dapz2izdwgxy8hrcxwgyacnnnj61cich2p46ni1pks6vz8i7swv";
  configurePhase = ''
    substituteInPlace src/lib.rs --replace "capnp_path" "${capnproto}/bin/capnp"
  '';
  meta = with stdenv.lib; {
    description = "Component: Fractalide Virtual Machine";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/fvm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
