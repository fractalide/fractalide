#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct node ((type string?)
                        (os-deps (listof string?))
                        (modules (listof string?)))]))

(struct node (type os-deps modules) #:prefab)
