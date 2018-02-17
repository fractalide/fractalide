#lang typed/racket

(provide write-edges-default-dot-nixes)

(: write-edges-default-dot-nixes (Path String -> Void))
(define (write-edges-default-dot-nixes path language)
  (write-file (build-path path "edges" "default.nix") edge-lang-template)
  (cond
    [(string=? language "rs")
     (write-file (build-path path "edges" "rs" "default.nix") rs-edge-template)]
    [(string=? language "rkt")
     (write-file (build-path path "edges" "rkt" "default.nix") rkt-edge-template)]))

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

}
EOM
  )