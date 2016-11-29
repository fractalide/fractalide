{ subnet, components, contracts }:

subnet {
 src = ./.;
 name = "lain";
 subnet = with components; with contracts; ''
   prompt(${shells_lain_prompt}) output ->
   input parse(${shells_lain_parse}) output ->
   input flow(${shells_lain_flow}) output ->
   flowscript scheduler(${nucleus_flow_subnet})
 '';
}
