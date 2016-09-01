{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , generic_tuple_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text generic_tuple_text ];
  depsSha256 = "00dnpk3ickx0njnr2n51vv46jj0hrs2svy15gy48rczcgz1lm3fh";

  meta = with stdenv.lib; {
    description = "Component: filter enter and escape keyup";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
