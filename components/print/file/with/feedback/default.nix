{ stdenv, buildFractalideComponent, genName, upkeepers
  , value_string
  , list_triple
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ value_string list_triple];
  depsSha256 = "040arrahy9hhj9n0mqandz5ckjv8l1qmjk6051hjvdd6sp0wlyqp";

  meta = with stdenv.lib; {
    description = "Component: Opens files";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
