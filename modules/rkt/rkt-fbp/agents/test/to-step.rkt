#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (define-agent
              #:input '("in")
              #:output '("out")
              #:proc (lambda (input output input-array output-array option)
                       (let* ([msg (recv (input "in"))]
                              [step (string->number (vector-ref msg 1))]
                              [step (or step 1)])
                         (send (output "out") step)))))
