{ stdenv, buildFractalideComponent, filterContracts, upkeepers, contracts, ...}:

buildFractalideComponent rec {
  name = "contract_lookup";
  src = ./.;
  filteredContracts = filterContracts ["path" "option_path"];
  depsSha256 = "0mhcw3q4ags4bdxcksjl67d6lqzyzk2c9xj1h7h8qmnqq48zy7jw";
  configurePhase = ''
runHook preConfigure
substituteInPlace src/lib.rs --replace "nix-replace-me" "${stdenv.lib.concatMapStringsSep "\n"
(pkg: ''\"${pkg.name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" pkg.outPath))}\")},'')
(stdenv.lib.attrValues contracts)}"
  '';
  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/build-support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
