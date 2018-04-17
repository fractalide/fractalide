#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)

(define agt (opt-agent
             '() ; in port
             '("in") ; in array port
             '("out") ; out port
             '() ; out array port
             (lambda (self)
               (let* ([in-array (agent-in-array-port self)]
                      [array (hash-ref in-array "in")])
                 (define sum (for/fold ([sum 0])
                                       ([(k v) array])
                               (+ sum (port-recv (cdr v)))))
                 (send self "out" sum)))))
