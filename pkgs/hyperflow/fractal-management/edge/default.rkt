#lang racket

(provide build-edge)

(require "../generic/paths.rkt")
(require "../generic/file-handling.rkt")

;(: build-edge (String String String -> Void))
(define (build-edge fractal-name language edge-name)
  (define node-path (make-edge-path fractal-name language edge-name))
  (define default-nix (component-list-default-nix fractal-name "edges" language))
  (make-directory* node-path)
  (write-edge-files node-path)
  (insert-raw-into-default default-nix "RAW EDGES" edge-name "edges"))

;(: write-edge-files (Path -> Void))
(define (write-edge-files path)
  (write-file (build-path path "default.nix") default-rs-nix)
  (write-file (build-path path "edge.rs") lib-rs))

;(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define default-rs-nix #<<EOM
{ edge, edges }:

edge.rs {
  src = ./.;
  edges =  with edges.rs; [ ];
}
EOM
  )

(define lib-rs #<<EOM
#[derive(Clone, Debug)]
pub struct Text (pub String);
EOM
  )