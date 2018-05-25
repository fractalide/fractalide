#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         racket/file)

(define agt
  (define-agent
    #:input '("in") ; in array port
    #:output '("out") ; out port
    #:proc
    (lambda (input output input-array output-array)
      (define msg (recv (input "in")))
      (define new-msg (cons (recv (input "option"))
                            (cdr msg)))
      (send (output "out") new-msg))))
