{ stdenv, buildFractalideComponent, genName, upkeepers
  , command, generic_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ command generic_text];
  depsSha256 = "046dvks494gqrqa7f3f8bpab25hhrirbqk6qs4b49pxbzgz0syqd";

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
