{ stdenv, buildFractalideComponent, filterContracts, upkeepers, components, contract_lookup, ...}:

buildFractalideComponent rec {
  name = "component_lookup";
  src = ./.;
  filteredContracts = filterContracts ["path" "option_path"];
  depsSha256 = "154zm5j4kds42179i7z028ix2cn39x75b0j4v4n8v9y2rrqkq2bg";
  configurePhase = ''
substituteInPlace src/lib.rs --replace "nix-replace-me" "${stdenv.lib.concatMapStringsSep "\n"
(pkg: ''\"${pkg.name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" pkg.outPath))}\")},'')
(stdenv.lib.attrValues components)}
\"${name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" (builtins.toPath "$out")))}\")},
\"${contract_lookup.name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" contract_lookup.outPath))}\")}, "

cat src/lib.rs
  '';
  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common component name";
    homepage = https://github.com/fractalide/fractalide/tree/master/build-support/component-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
