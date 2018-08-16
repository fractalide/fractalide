#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct node ((id string?)
                        (x number?)
                        (y number?)
                        (name string?))]))

(struct node (id x y name) #:prefab #:mutable)
