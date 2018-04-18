#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (opt-agent
             '("in") ; in port
             '() ; in array port
             '() ; out port
             '("out") ; out array port
             (lambda (input output input-array output-array option)
               (let* ([msg (recv (input "in"))])
                 (for ([(k v) (output-array "out")])
                   (send v msg))))))
