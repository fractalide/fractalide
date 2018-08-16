#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
  (fun
   (define msg (recv (input "in")))
   (sleep 2)
   (send (output "out") msg)))
