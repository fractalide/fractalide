{ buffet }:

# Please refer to section 2.6 namely Evolution of Public Contracts
# of the Collective Code Construction Contract in CONTRIBUTING.md
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs // buffet.support.node.idr // buffet.support // buffet.mods // buffet);
in
{
  # RAW NODES
  # -   raw nodes are incomplete and immature, they may wink into and out of existance
  # -   use at own risk, anything in this section can change at any time.

  maths = callPackage ./maths {};

  # DRAFT NODES
  # -   draft nodes change a lot in tandom with other nodes in their subgraph
  # -   there will be change in these nodes and few people are using these nodes so expect breakage

  # STABLE NODES
  # -   stable nodes do not change names of ports, agents nor subgraphs,
  # -   you may add new port names, but never change, nor remove port names

  # DEPRECATED NODES
  # -   deprecated nodes do not change names of ports, agents nor subgraphs.
  # -   keep the implementation functioning, print a warning message and tell users to use replacement node

  # LEGACY NODES
  # -   legacy nodes do not change names of ports, agents nor subgraphs.
  # -   assert and remove implementation of the node.
}
