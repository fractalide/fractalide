{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ generic_text ];
  depsSha256 = "0nh85zb5336s8h1b9pljqacd3n9wrqnnkzflqp8kjrgc5rsgq3rd";
}
