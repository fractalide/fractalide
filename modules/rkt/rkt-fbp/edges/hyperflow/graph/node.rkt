#lang racket

(require fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/graph)

(provide (contract-out
          [struct node ((id string?)
                        (x number?)
                        (y number?)
                        (name string?)
                        (type string?)
                        (raw (or/c opt-agent? graph? boolean?)))]))

(struct node (id x y name type raw) #:prefab #:mutable)
