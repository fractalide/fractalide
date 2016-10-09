{ stdenv, buildFractalideComponent, upkeepers, path, option_path, ...}:

buildFractalideComponent rec {
  name = "nucleus_find_contract";
  src = ./.;
  contracts = [ path option_path ];
  depsSha256 = "08i8n3z0ylvsd69f0w8b6756p5nydhgah8m8xq9bfh2pv65mnqac";

  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, after given the common contract name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/contract-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
