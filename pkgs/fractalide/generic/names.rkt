#lang typed/racket

(provide edge-nix-attr node-nix-attr)

(require typed-map)

(: comp_name->CompName (String -> String))
(define (comp_name->CompName comp-name)
  (string-join (map string-titlecase (string-split comp-name "_"))""))


(: comp_name->nix-path-string (String -> String))
(define (comp_name->nix-path-string comp-name)
  (string-append "./" (string-join (string-split comp-name "_") "/")))

(: edge-nix-attr (String -> String))
(define (edge-nix-attr comp-name)
  (string-append (comp_name->CompName comp-name)
                 " = callPackage "
                 (comp_name->nix-path-string comp-name)
                 " {};"))

(: node-nix-attr (String -> String))
(define (node-nix-attr comp-name)
  (string-append comp-name
                 " = callPackage "
                 (comp_name->nix-path-string comp-name)
                 " {};"))
