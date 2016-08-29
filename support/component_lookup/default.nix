{ stdenv, buildFractalideComponent, upkeepers, components, all_contracts, ...}:

buildFractalideComponent rec {
  name = "component_lookup";
  src = ./.;
  contracts = [ all_contracts.path all_contracts.option_path ];
  depsSha256 = "01507jvikv5s4y8arm3c4f3p3hnj3xm944h3gh8m8ayjs9p036qv";
  configurePhase = ''
runHook preConfigure
substituteInPlace src/lib.rs --replace "nix-replace-me" "${stdenv.lib.concatMapStringsSep "\n"
(pkg: ''\"${pkg.name}\" => { Some (\"${pkg.outPath}\")},'')
(stdenv.lib.attrValues components)}"
  '';  
  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common component name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/component-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
