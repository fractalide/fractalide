{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ list_text ];
  crates = with crates; [];
  depsSha256 = "07vdmypmqh72f0rdl1f0mqsc4w2rl27yl29aywysjnlmkpyg4cgc";
}
