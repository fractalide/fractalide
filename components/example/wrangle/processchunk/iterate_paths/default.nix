{ stdenv, buildFractalideComponent, genName, upkeepers
  , file_list
  , path
  , value_string
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ file_list path value_string ];
  depsSha256 = "0w7mmxcs4mzv6zy7kay5d6vmka77x0phvcvhjdfysm9gaj78ddk4";

  meta = with stdenv.lib; {
    description = "Component: Iterate over a list of 1000 file paths";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangler/iterate_paths;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
