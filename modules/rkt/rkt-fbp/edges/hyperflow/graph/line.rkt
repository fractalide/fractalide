#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct line ((id string?)
                        (x number?)
                        (y number?)
                        (x-end number?)
                        (y-end number?))]))

(struct line (id x y x-end y-end) #:prefab)
