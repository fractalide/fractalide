#lang typed/racket

(provide write-nodes-default-dot-nixes)

(: write-nodes-default-dot-nixes (Path String -> Void))
(define (write-nodes-default-dot-nixes path language)
  (cond
    [(string=? language "rs")
     (write-file (build-path path "nodes" "default.nix") rs-nodes-template)
     (write-file (build-path path "nodes" "rs" "default.nix") rs-nodes)]
    [(string=? language "rkt")
     (write-file (build-path path "nodes" "default.nix") rkt-nodes-template)
     (write-file (build-path path "nodes" "rkt" "default.nix") rkt-nodes)]))

(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define rs-nodes-template #<<EOM
{ buffet }:
{
  rs = import ./rs { inherit buffet; };
}
EOM
  )

(define rkt-nodes-template #<<EOM
{ buffet }:
{
  rkt = import ./rkt { inherit buffet; };
}
EOM
  )

(define nodes-header-template #<<EOM
{ buffet }:

# Please refer to section 2.6 namely Evolution of Public Contracts
# of the Collective Code Construction Contract in CONTRIBUTING.md
let
EOM
  )

(define nodes-rs-template #<<EOM
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs // buffet.support.node.rs // buffet.support // buffet );
EOM
  )

(define nodes-rkt-template #<<EOM
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.pkgs // buffet.support.node.rkt // buffet.support // buffet );
EOM
  )

(define nodes-footer-template #<<EOM
in
{
  # RAW NODES
  # -   raw nodes are incomplete and immature, they may wink into and out of existance
  # -   use at own risk, anything in this section can change at any time.

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
EOM
  )

(: rs-nodes String)
(define rs-nodes
  (string-append nodes-header-template nodes-rs-template nodes-footer-template))

(: rkt-nodes String)
(define rkt-nodes
  (string-append nodes-header-template nodes-rkt-template nodes-footer-template))
