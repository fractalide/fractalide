#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct node ((x number?)
                        (y number?)
                        (name string?))]))

(struct node (x y name) #:prefab)
