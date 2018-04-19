#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out") ; out port
              #:proc (lambda (input output input-array output-array option)
                       (define msg (recv (input "in")))
                       (if option
                           (display option)
                           (void))
                       (displayln msg)
                       (send (output "out") msg))))
