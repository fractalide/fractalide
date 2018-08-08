#lang racket


(require fractalide/modules/rkt/rkt-fbp/def
         racket/gui/base)

(provide (contract-out
          [struct snip ([id number?]
                        [x number?]
                        [y number?]
                          [snip (is-a?/c snip%)]
                          [event (-> any/c void?)]
                          )]))

(struct snip (id x y snip event) #:prefab)
