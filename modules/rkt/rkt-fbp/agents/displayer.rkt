#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
   (define msg (recv (input "in")))
   (define option (try-recv (input "option")))
   (if option
       (display option)
       (void))
   (displayln msg)
   (send (output "out") msg))
