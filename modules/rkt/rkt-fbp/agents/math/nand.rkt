#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (define-agent
              #:input '("x" "y") ; in port
              #:output '("res") ; out port
              #:proc (lambda (input output input-array output-array)
                       (define x (recv (input "x")))
                       (define y (recv (input "y")))
                       (send (output "res") (not (and x y))))))
