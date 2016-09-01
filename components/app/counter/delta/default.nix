{ stdenv, buildFractalideComponent, genName, upkeepers
  , app_counter
  , generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ app_counter generic_text ];
  depsSha256 = "00dnpk3ickx0njnr2n51vv46jj0hrs2svy15gy48rczcgz1lm3fh";

  meta = with stdenv.lib; {
    description = "Component: increase by one the number";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
