
{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_text

, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [generic_text list_text];
  depsSha256 = "1aip13fz36sfika4ag3cyhxnqyg02m7vqjp2wpv689vamipax0lc";

  meta = with stdenv.lib; {
    description = "Component: shells_fsh_generator_nix";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/flow;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
