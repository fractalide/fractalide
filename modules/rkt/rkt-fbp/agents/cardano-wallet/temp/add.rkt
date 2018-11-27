#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (define msg (recv (input "in")))
  (model-add-wallet! msg (wallet 0 "cli" 0))
  (model-add-wallet! msg (wallet 0 "cli2" 10))
  (send (output "out") (cons 'set msg)))

