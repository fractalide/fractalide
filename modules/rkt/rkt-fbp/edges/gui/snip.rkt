#lang racket


(require fractalide/modules/rkt/rkt-fbp/def
         racket/gui/base)

(provide (contract-out
          [struct snip ([id (or/c string? number?)]
                        [x number?]
                        [y number?]
                        [snip (is-a?/c snip%)]
                        )]))

(struct snip (id x y snip) #:prefab)
