{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ui_magic, ui_conrod_window, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["fbp_graph" "path" "generic_text"];
  depsSha256 = "1lri4ra9f7364jib0yqbdvpn1qckh7wqwgzc18g76vfzxn7b7jd1";
  configurePhase = ''
  substituteInPlace src/lib.rs --replace "ui_magic" "${ui_magic}"
  substituteInPlace src/lib.rs --replace "ui_conrod_window" "${ui_conrod_window}"
'';

  meta = with stdenv.lib; {
    description = "Component: Fractalide scheduler";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/fvm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
