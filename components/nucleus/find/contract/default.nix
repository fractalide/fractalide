{ stdenv, buildFractalideComponent, upkeepers, path, option_path, ...}:

buildFractalideComponent rec {
  name = "nucleus_find_contract";
  src = ./.;
  contracts = [ path option_path ];
  depsSha256 = "1hxaxq57rnjli8d89wxfrsbd7vv56sckl4nz1zn5xvr6l740xf2m";

  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
