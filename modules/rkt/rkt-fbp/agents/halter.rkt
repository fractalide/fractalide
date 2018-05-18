#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt
  (define-agent
    #:input '("in") ; in port
    #:proc
    (lambda (input output input-array output-array)
      (define msg (recv (input "in")))
      (define msg2 (recv (input "in")))
      (void))))
