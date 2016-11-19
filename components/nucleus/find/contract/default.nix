{ stdenv, buildFractalideComponent, upkeepers, path, option_path, ...}:

buildFractalideComponent rec {
  name = "nucleus_find_contract";
  src = ./.;
  contracts = [ path option_path ];
  depsSha256 = "0hs5ayg0y6afzbq90n6g2haw8ss4k3fkznp42i82wvbrl0gb4cdb";

  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
