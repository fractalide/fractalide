#lang racket

(require graph)
(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct raw-graph ((graph graph?)
                             (nodes (and/c hash? hash-equal?))
                             (build-edge (or/c boolean? string?))
                             (last-click exact-integer?))]))

(struct raw-graph (graph
                   nodes
                   build-edge
                   last-click) #:prefab #:mutable)
