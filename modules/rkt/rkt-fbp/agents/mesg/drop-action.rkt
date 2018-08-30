#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         racket/file)

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
    (define msg (recv (input "in")))
    (send (output "out") (cdr msg)))
