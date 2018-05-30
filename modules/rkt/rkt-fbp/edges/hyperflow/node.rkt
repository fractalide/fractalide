#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct node ((type string?))]))

(struct node (type) #:prefab)
