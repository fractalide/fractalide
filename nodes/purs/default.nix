{ buffet }:
let

callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs // buffet.support.purs // buffet.support // buffet);
# Insert in alphabetical order in relevant section to reduce conflicts
# This system grows by the slow accretion of nodes.
# Once a node is declared stable, it is _/forbidden/_ to:
# * change the node name
# * change any port name
# * delete a node, or port
# * change or delete items in the schema on any port, though additions of schema items are acceptable
# * backtrack towards the experimental category
# Once a node becomes stable, all associated schema also become stable.
# Nodes should function reliably decades from now.
# Changing names after experimental upgrade is a breaking change, we do not do that here.
self = rec {

  # RAW NODES
  # -   are incomplete and immature, they may wink into and out of existance
  # -   use at own risk, anything in this section can change at any time.

  test = callPackage ./test {};

  # DRAFT NODES
  # -   draft nodes change a lot in tandom with other nodes in their subgraph
  # -   there will be change in these nodes
  # -   few people are using these nodes so expect breakage


  # STABLE NODES
  # -   do not change names of ports, agents nor subgraphs,
  # -   you may add new port names, but never change, nor remove port names
  # -   never change or remove schema names
  # -   you may add new schema items S

  # DEPRECATED NODES
  # -   do not change names of ports, agents nor subgraphs.
  # -   keep the implemenation functioning
  # -   print a warning message and tell users to use replacement node

  # LEGACY NODES
  # -   do not change names of ports, agents nor subgraphs.
  # -   assert and remove implementation
};
in
self
