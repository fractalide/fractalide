#lang racket


(require fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${guiv2.counter})

(provide (contract-out
          [struct list-counter ([next-id number?]
                                [counters (listof counter?)]
                                )]))

(struct list-counter (next-id counters) #:prefab)
