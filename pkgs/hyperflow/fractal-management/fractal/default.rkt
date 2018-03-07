#lang racket

(provide fractal-exists? build-fractal)

(require "../generic/paths.rkt")
(require "../generic/generic.rkt")
(require "fractal-default-dot-nix.rkt")
(require "fractal-edges-default-dot-nixes.rkt")
(require "fractal-mods-default-dot-nixes.rkt")
(require "fractal-nodes-default-dot-nixes.rkt")

;(: fractal-exists? (String -> Boolean))
(define (fractal-exists? fractal)
  (directory-exists? (make-fractal-path fractal)))
(define rust-dirs (list "edges/rs" "mods/rs/crates/src" "nodes/rs"))
(define racket-dirs (list "edges/rkt" "mods/rkt" "nodes/rkt"))

;(: build-paths (Path (Listof String) -> (Listof Path)))
(define (build-paths fractal-path lst)
  (cond
   [(empty? lst) empty]
   [else (cons (build-path fractal-path (first lst))
               (build-paths fractal-path (rest lst)))]))

;(: make-dirs (Path String -> (Listof Void)))
(define (make-dirs fractal-path language)
  (if (string=? language "rs")
      (map make-directory* (build-paths fractal-path rust-dirs))
      (map make-directory* (build-paths fractal-path racket-dirs))))

;(: build-fractal (String String -> Void))
(define (build-fractal fractal-name language)
  (define fractal-path (make-fractal-path fractal-name))
  (make-dirs fractal-path language)
  (write-default-dot-nix fractal-path)
  (write-generics-files fractal-path)
  (write-edges-default-dot-nixes fractal-path language)
  (write-mods-default-dot-nixes fractal-path language)
  (write-nodes-default-dot-nixes fractal-path language))

