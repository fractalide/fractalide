#lang racket

(provide build-subgraph)

(require "../generic/paths.rkt")

;(: build-subgraph (String String String -> Void))
(define (build-subgraph fractal-name language node-name)
  (define node-path (make-node-path fractal-name language node-name))
  (make-directory* node-path)
  (write-subgraph-file node-path language))

;(: write-subgraph-file (Path String -> Void))
(define (write-subgraph-file path language)
  (if (string=? "rs" language)
      (write-file (build-path path "default.nix") subgraph-rs-nix)
      (write-file (build-path path "default.nix") subgraph-rkt-nix)))

;(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define subgraph-rs-nix #<<EOM
{ subgraph, imsg, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes.rs; ''
   '';
}
EOM
  )

(define subgraph-rkt-nix #<<EOM
{ subgraph, imsg, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes.rkt; ''
   '';
}
EOM
  )