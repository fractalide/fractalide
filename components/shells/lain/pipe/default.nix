{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text list_text];
  depsSha256 = "1600c5mwyp3v8cnr9rrnjbmlwgn93vch8yhmid5z5fwjqx4dgw1a";

  meta = with stdenv.lib; {
    description = "Component: shells_lain_pipe: create pipes.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/parse/pipe;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
