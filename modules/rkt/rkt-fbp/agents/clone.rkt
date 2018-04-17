#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)

(define agt (opt-agent
             '("in") ; in port
             '() ; in array port
             '() ; out port
             '("out") ; out array port
             (lambda (self)
               (let* ([msg (recv self "in")]
                     [out-array (agent-out-array-port self)]
                     [array (hash-ref out-array "out")])
                 (for ([(k v) array])
                   (port-send v msg))))))
