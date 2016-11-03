
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, file_desc, list_command

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [file_desc list_command];
  depsSha256 = "10rzaq5x7s8pdawljz4sri1xva7ng7kjg8ypm0mbqz0bdbv6h763";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/flow;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
