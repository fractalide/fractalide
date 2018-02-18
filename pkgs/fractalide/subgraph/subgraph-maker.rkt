#lang typed/racket

(provide build-subgraph)

(require "../generic/paths.rkt")

(: build-subgraph (String String String -> Void))
(define (build-subgraph fractal-name language node-name)
  (define node-path (make-node-path fractal-name language node-name))
  (make-directory* node-path)
  (write-subgraph-file node-path)
  )

(: write-subgraph-file (Path -> Void))
(define (write-subgraph-file path)
  (write-file (build-path path "default.nix") subgraph-rs-nix)
  )

(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define subgraph-rs-nix #<<EOM
{ subgraph, imsg, nodes, edges }:

subgraph {
  src = ./.;
  flowscript = with nodes.rs; ''
  '${PrimText}' -> option extract_kvs(${example_wrangle_processchunk_extract_keyvalue})
   '';
}
EOM
  )