#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require fractalide/modules/rkt/rkt-fbp/def)

(require racket/match)

(define agt (define-agent
              #:input '("in")
              #:output '("out")
              #:proc (lambda (input output input-array output-array)
                       (let* ([sched (recv (input "acc"))]
                              [msg (recv (input "in"))])
                         (sched msg)
                         (send (output "acc") sched))
                       )))
