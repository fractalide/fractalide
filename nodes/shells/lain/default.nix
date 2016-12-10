{ subgraph, nodes, edges }:

subgraph {
 src = ./.;
 name = "lain";
 flowscript = with nodes; with edges; ''
   prompt(${shells_lain_prompt}) output ->
   input parse(${shells_lain_parse}) output ->
   input flow(${shells_lain_flow}) output ->
   flowscript scheduler(${nucleus_flow_subgraph})
 '';
}
