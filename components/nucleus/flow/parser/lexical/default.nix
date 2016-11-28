{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ file_desc fbp_lexical ];
  depsSha256 = "12sygxr7mm5s1lrg665dy7g6f2bq9macmlmfm2bazf3ahnsxgrbw";
}
