{ stdenv, buildFractalideComponent, upkeepers, path, option_path
  , nix
  , ...}:

buildFractalideComponent rec {
  name = "nucleus_find_component";
  src = ./.;
  contracts = [ path option_path ];
  depsSha256 = "1rd6nq9zqh5x9lkk49l7glpc3627g2g0zm0s2rjd9bh81h61vyrv";
  buildInputs = [ nix ];

  meta = with stdenv.lib; {
    description = "Component: Looks up the versioned name, given the common component name";
    homepage = https://github.com/fractalide/fractalide/tree/master/support/component-lookup;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
