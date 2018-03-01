#lang typed/racket

(provide make-fractal-path fractal-exists?
         make-node-path node-exists?
         make-edge-path edge-exists?
         node-name->path component-list-default-nix)

;(define fract-env (assert (getenv "FRACTALIDE")))
(define fract-env "../../../../")

(: node-name->path (String -> Path))
(define (node-name->path node-name)
  (string->path (string-join (string-split node-name "_") "/")))

(: make-fractal-path (String -> Path))
(define (make-fractal-path fractal-name)
  (simplify-path (build-path fract-env 'up "fractal" fractal-name)))

(: fractal-exists? (String -> Boolean))
(define (fractal-exists? fractal-name)
  (directory-exists? (make-fractal-path fractal-name)))

(: make-node-path (String String String -> Path))
(define (make-node-path fractal-name language node-name)
  (if (string=? fractal-name "fractalide")
      (build-path fract-env "nodes" language (node-name->path node-name))
      (build-path (make-fractal-path fractal-name) "nodes" language
                  (node-name->path node-name))))

(: node-exists? (String String String -> Boolean))
(define (node-exists? fractal language node-name)
  (directory-exists? (make-node-path fractal language node-name)))

(: make-edge-path (String String String -> Path))
(define (make-edge-path fractal-name language node-name)
  (if (string=? fractal-name "fractalide")
      (build-path fract-env "edges" language (node-name->path node-name))
      (build-path (make-fractal-path fractal-name) "edges" language
                  (node-name->path node-name))))

(: edge-exists? (String String String -> Boolean))
(define (edge-exists? fractal language node-name)
  (directory-exists? (make-edge-path fractal language node-name)))

(: component-list-default-nix (String String String -> Path))
(define (component-list-default-nix fractal-name component language)
  (if (string=? fractal-name "fractalide")
      (build-path fract-env component language)
      (build-path (make-fractal-path fractal-name) component language "default.nix")))