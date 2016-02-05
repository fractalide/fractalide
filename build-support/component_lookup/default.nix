{ stdenv, buildFractalideComponent, filterContracts, upkeepers, components, contract_lookup, ...}:

buildFractalideComponent rec {
  name = "component_lookup";
  src = ./.;
  filteredContracts = filterContracts ["path" "option_path"];
  depsSha256 = "0bcv27wqi1lgvh15yw0hf0q73wmm9df0nzb6spyxfin1j2gvsf94";
  configurePhase = ''
substituteInPlace src/lib.rs --replace "nix-replace-me" "${stdenv.lib.concatMapStringsSep "\n"
(pkg: ''\"${pkg.name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" pkg.outPath))}\")},'')
(stdenv.lib.attrValues components)}
\"${name}\" => { Some (\"$(basename "$out")\") },
\"${contract_lookup.name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" contract_lookup.outPath))}\")}, "
  '';
  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common component name";
    homepage = https://github.com/fractalide/fractalide/tree/master/build-support/component-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
