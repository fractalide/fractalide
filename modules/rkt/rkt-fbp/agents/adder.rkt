#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)

(define agt (opt-agent
             '("in") ; in port
             '() ; in array port
             '("out") ; out port
             '() ; out array port
             (lambda (self)
               (let ([msg (recv self "in")])
                 (send self "out" (+ msg 10))))))
