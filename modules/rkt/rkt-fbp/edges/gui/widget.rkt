#lang racket


(require fractalide/modules/rkt/rkt-fbp/def
         racket/gui/base)

(provide (contract-out
          [struct widget ([id (or/c string? number?)]
                          [draw (-> boolean?
                                    (is-a?/c dc<%>)
                                    real? real? real? real?
                                    real? real?
                                    void?)]
                          [box (-> (is-a?/c dc<%>) number? number? boolean?)]
                          [event (-> any/c void?)]
                          )]))

(struct widget (id draw box event) #:prefab)
