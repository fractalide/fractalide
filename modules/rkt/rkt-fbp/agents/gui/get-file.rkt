#lang racket/base

(require (prefix-in gui: racket/gui))

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
   (define msg (recv (input "in")))
   (define option (try-recv (input "option")))
   (define path (gui:get-file))
   (send (output "out") (path->string path)))
