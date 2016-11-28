{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text app_counter generic_tuple_text ];
  crates = with crates; [];
  depsSha256 = "0yav2znjhqlqh6f17jn8sjdk7sf7wxjm5y6df8nxmgiv14x5ln1f";
}
