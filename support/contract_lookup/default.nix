{ stdenv, buildFractalideComponent, upkeepers, all_contracts
  , ...}:

buildFractalideComponent rec {
  name = "contract_lookup";
  src = ./.;
  contracts = [ all_contracts.path all_contracts.option_path ];
  depsSha256 = "0p48flmsnslnj4rzflh9nlbmifiljldil560j9sa74gm6sqldma5";
  configurePhase = ''
runHook preConfigure
substituteInPlace src/lib.rs --replace "nix-replace-me" "${stdenv.lib.concatMapStringsSep "\n"
(pkg: ''\"${pkg.name}\" => { Some (\"${(stdenv.lib.last (stdenv.lib.splitString "/" pkg.outPath))}\")},'')
(stdenv.lib.attrValues all_contracts)}"
  '';
  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
