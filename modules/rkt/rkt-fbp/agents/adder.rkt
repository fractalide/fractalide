#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)

(define agt (opt-agent '("in") '("out")
                         (lambda (self)
                           (let ([msg (recv self "in")])
                             (send self "out" (+ msg 10))))))
