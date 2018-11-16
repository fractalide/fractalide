#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.wcreate})

(define-agent
  #:input '("data" "trigger")
  #:output '("out" "msg")
  (define msg (recv (input "data")))


  (define text "")
  (send (output "msg") (cons 'init (list (cons 'label text))))

  (recv (input "trigger"))
  (send (output "out") msg)
  )
