{ stdenv, buildFractalideComponent, genName, upkeepers
# contracts:
, generic_text, list_list_list_text
, ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text list_list_list_text ];
  depsSha256 = "0chb6l1pv7jry7gn7maxfh2iazzyqsvsn50xcvi6sqv4cxyhs8m6";

  meta = with stdenv.lib; {
    description = "Component: shells_lain_parse: commands go in and flow script comes out.";
    homepage = https://gitlab.com/fractalide/fractalide/tree/master/components/shells/lain/parse;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
