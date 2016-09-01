{ stdenv, buildFractalideComponent, upkeepers, all_contracts, ...}:

buildFractalideComponent rec {
  name = "contract_lookup";
  src = ./.;
  contracts = [ all_contracts.path all_contracts.option_path ];
  depsSha256 = "1j634grsyc9hd4f7majfs7382rv4x4l29i6c21rsnmrlwzfby50v";
  configurePhase = ''
runHook preConfigure
substituteInPlace src/lib.rs --replace "nix-replace-me" "${stdenv.lib.concatMapStringsSep "\n"
(pkg: ''\"${pkg.name}\" => { Some (\"${pkg.outPath}\")},'')
(stdenv.lib.attrValues all_contracts)}"
  '';
  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
