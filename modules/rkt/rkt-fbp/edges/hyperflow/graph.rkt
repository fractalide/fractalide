#lang racket

(require graph)
(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct raw-graph ((graph graph?)
                             (build-edge (or/c boolean? string?))
                             (build-edge-id number?)
                             (last-click exact-integer?))]))

(struct raw-graph (graph build-edge build-edge-id last-click) #:prefab #:mutable)
