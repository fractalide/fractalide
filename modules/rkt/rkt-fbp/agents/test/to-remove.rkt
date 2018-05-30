#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)

(define-agent
  #:input '("in")
  #:output '("out")
  (fun
    (let* ([msg (recv (input "in"))])
      (send (output "out") (cons 'remove #t)))))
