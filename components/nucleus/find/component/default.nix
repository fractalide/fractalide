{ stdenv, buildFractalideComponent, upkeepers, path, option_path
  , nix
  , ...}:

buildFractalideComponent rec {
  name = "nucleus_find_component";
  src = ./.;
  contracts = [ path option_path ];
  depsSha256 = "0n5hq4lci1y54fkgbcnc3bpsbaghhwxp0w9rs7yzyqzih00mqyz0";
  buildInputs = [ nix ];

  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, given the common component name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/component-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
