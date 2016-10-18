{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , generic_tuple_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text generic_tuple_text ];
  depsSha256 = "0745h7nwq1v5f8d8325pq9kkkhkxn4rpxbr7psndrsbg6w7606k2";

  meta = with stdenv.lib; {
    description = "Component: split the fbp_graph in different ui_js components";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
