#lang racket

(provide agt)

(require rkt-fbp/agent)
(require rkt-fbp/port)

(define agt (opt-agent '("in") '()
                             (lambda (self)
                               (display "msg received: ")
                               (displayln (recv self "in")))))
