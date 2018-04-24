#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)


(define agt (define-agent
              #:input '("in")
              #:output '("out")
              #:proc (lambda (input output input-array output-array option)
                       (let* ([agt (recv (input "in"))])
                         (define new-type (string-append "agents/" (g-agent-type agt) ".rkt"))
                         (define new-agent (struct-copy g-agent agt
                                                        [type new-type]))
                           (send (output "out") new-agent)))))
