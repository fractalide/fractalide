{ stdenv, buildFractalideComponent, filterContracts, genName, upkeepers, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  filteredContracts = filterContracts ["generic_text" "fbp_graph"];
  depsSha256 = "1dn89bm45mnqmyh8smbkxkxswjzp0y20s1i0fhxvbw1d7na4bvsw";

  meta = with stdenv.lib; {
    description = "Component: split the fbp_graph in different ui_js components";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/app/editor/view;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
