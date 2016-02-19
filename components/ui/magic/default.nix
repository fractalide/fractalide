{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts [];
  configurePhase = ''
    substituteInPlace src/lib.rs --replace "ui_magic" "${ui_magic}/lib/libcomponent.so"
    '';
  depsSha256 = "1cnkva10a3ap9qlrl1q0qdspd3a81v8nzr5c9pxi2sb7wl3sdi50";

  meta = with stdenv.lib; {
    description = "Component: dispatch the action to the output selection";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/ip/clone;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
