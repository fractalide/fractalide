#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})
(require/edge ${fvm.dynamic-add})

(define-agent
  #:input '("in") ; in array port
  #:output '("out" "text-field") ; out port
  (define msg (recv (input "in")))
  (define opt (recv (input "option")))
  (send (output "text-field") '(set-value . ""))
  (send (output "out") (cdr opt)))
