#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.wcreate})

(define-agent
  #:input '("data" "trigger")
  #:output '("out")
  (define msg (recv (input "data")))
  (recv (input "trigger"))
  (send (output "out") msg)
  )
