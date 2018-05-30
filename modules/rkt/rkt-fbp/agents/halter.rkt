#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in") ; in port
  (fun
   (define msg (recv (input "in")))
   (define msg2 (recv (input "in")))
   (void)))
