{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, capnproto, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "path"];
  depsSha256 = "0vjigcl0091slb53vaciswqikrx5wn7cr5r2xrrai1r23hg59ia9";
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
