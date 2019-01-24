#lang racket


(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct counter ([id number?]
                           [val number?]
                           )]))

(struct counter (id val) #:prefab)
