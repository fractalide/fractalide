#lang racket

(provide agt)

(require rkt-fbp/agent)
(require rkt-fbp/port)

(define agt (opt-agent '("in") '("out")
                         (lambda (self)
                           (let ([msg (recv self "in")])
                             (send self "out" (+ msg 10))))))
