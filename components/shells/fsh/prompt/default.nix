
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text];
  depsSha256 = "0cqmfsk6nj7mfzs69shhyrwa5w3hyrwn8y6xkxhkzaa69sihidvz";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh: a shell prompt.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/maths/boolean/nand;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
