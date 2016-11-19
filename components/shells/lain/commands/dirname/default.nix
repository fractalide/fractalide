{ stdenv, buildFractalideComponent, genName, upkeepers
  , command, generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ command generic_text];
  depsSha256 = "1sg34dc83fpjrl8fdx8w26sr3cra8jxqqzjin0wdkwm6grrypmap";

  meta = with stdenv.lib; {
    description = "Component: dirname is a standard UNIX computer program.
    When dirname is given a pathname, it will delete any suffix beginning with the
    last slash character and return the result. dirname is described in the Single
    UNIX Specification and is primarily used in shell scripts.";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/shells/lain/commands/dirname;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
