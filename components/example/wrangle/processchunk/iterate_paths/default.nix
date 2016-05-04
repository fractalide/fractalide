{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["file_list" "path" "value_string"];
  depsSha256 = "0jnrcql4r8q2z3q2bbidywh6r0gi8g60b5vlrq2nh5ybx97sm0g7";

  meta = with stdenv.lib; {
    description = "Component: Iterate over a list of 1000 file paths";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/example/wrangler/iterate_paths;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
