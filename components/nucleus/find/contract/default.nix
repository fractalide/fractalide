{ stdenv, buildFractalideComponent, upkeepers, path, option_path, ...}:

buildFractalideComponent rec {
  name = "nucleus_find_contract";
  src = ./.;
  contracts = [ path option_path ];
  depsSha256 = "16ivz8w03xz774mr0zw0g6zpd0r77xk19g3lhbgqsbkrw3pj5s8g";

  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
