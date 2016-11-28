{ component, contracts }:

component {
  src = ./.;
  contracts = with contracts; [ fbp_graph path option_path ];
  depsSha256 = "1g46ac4gqf45c567fgf8hrdpdhgd8hq0vpcnz68q1jf0hgggg3kw";
}
