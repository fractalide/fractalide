#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct line ((x number?)
                        (y number?)
                        (x-end number?)
                        (y-end number?))]))

(struct line (x y x-end y-end) #:prefab)
