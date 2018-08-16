#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct mesg ((id string?)
                        (x number?)
                        (y number?)
                        (mesg string?))]))

(struct mesg (id x y mesg) #:prefab #:mutable)
