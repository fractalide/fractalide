#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)

(define agt (opt-agent '("in") '()
                             (lambda (self)
                               (display "msg received: ")
                               (displayln (recv self "in")))))
