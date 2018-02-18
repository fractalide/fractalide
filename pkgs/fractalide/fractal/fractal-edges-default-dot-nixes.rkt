#lang typed/racket

(provide write-edges-default-dot-nixes)

(: write-edges-default-dot-nixes (Path String -> Void))
(define (write-edges-default-dot-nixes path language)
  (cond
    [(string=? language "rs")
     (write-file (build-path path "edges" "default.nix") rs-edge-template)
     (write-file (build-path path "edges" "rs" "default.nix") edge-lang-template)]
    [(string=? language "rkt")
     (write-file (build-path path "edges" "default.nix") rkt-edge-template)
     (write-file (build-path path "edges" "rkt" "default.nix") edge-lang-template)]))

(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define rs-edge-template #<<EOM
{ buffet }:
{
  rs = import ./rs { inherit buffet; };
}
EOM
  )

(define rkt-edge-template #<<EOM
{ buffet }:
{
  rkt = import ./rkt { inherit buffet; };
}
EOM
  )

(define edge-lang-template #<<EOM
{ buffet }:
let
  callPackage = buffet.pkgs.lib.callPackageWith ( buffet.support // buffet );
in
rec {
  # RAW EDGES
  # -   raw edges are incomplete and immature, they may wink into and out of existance
  # -   use at own risk, anything in this section can change at any time.

  # DRAFT EDGES
  # -   draft edges change a lot in tandom with other edges in their subgraph
  # -   there will be change in these edges and few people are using these edges so expect breakage

  # STABLE EDGES
  # -   stable edges do not change structure nor types,
  # -   you may extend attributes, but never change, nor remove existing names

  # DEPRECATED EDGES
  # -   deprecated edges do not change structure nor types.
  # -   keep the implementation functioning

  # LEGACY EDGES
  # -   legacy edges do not change structure nor types.
  # -   assert and remove implementation of the edge, do not reuse the name.
}
EOM
  )