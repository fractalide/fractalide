{ agent, edges, crates, pkgs }:

agent  {
  src = ./.;
  edges = with edges; [ generic_text ];
  crates = with crates; [ rustfbp capnp ];
  osdeps = with pkgs; [];
  depsSha256 = "1k6yza5c5kb04mj83di8m63hj4l3ksalwl5dbv6d3liaf1fb7s3x";
}
