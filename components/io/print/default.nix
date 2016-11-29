{ component, contracts, crates }:

component  {
  src = ./.;
  contracts = with contracts; [ generic_text ];
  crates = with crates; [];
  depsSha256 = "1k6yza5c5kb04mj83di8m63hj4l3ksalwl5dbv6d3liaf1fb7s3x";
}
