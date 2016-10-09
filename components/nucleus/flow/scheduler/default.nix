{ stdenv, buildFractalideComponent, genName, upkeepers
  , fbp_graph
  , path
  , generic_text
  , fbp_action
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ fbp_graph path generic_text fbp_action ];
  depsSha256 = "0mzb6psk49s03jw76s3g2mkcnkls9v16i3c2vqqp9ynvgjpxfiis";

  meta = with stdenv.lib; {
    description = "Component: Fractalide scheduler";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/development/vm;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels ];
  };
}
