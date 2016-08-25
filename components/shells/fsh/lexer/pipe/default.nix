{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text list_text];
  depsSha256 = "0gsf9cl0s6yvhma8iidvksp5pk4lb169qk0f2slqhf09rgdarpak";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_parse_pipe: create pipes.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/fsh/parse/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
