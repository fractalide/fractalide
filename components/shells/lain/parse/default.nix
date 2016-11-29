{ component, contracts, crates }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text list_command ];
  crates = with crates; [];
  depsSha256 = "0asjb34jfhmx2358rjqbyqvmy95011avz4x40p01l0zf0bwrb8n2";
}
