#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (opt-agent
             '("in") ; in port
             '() ; in array port
             '("out") ; out port
             '() ; out array port
             (lambda (input output input-array output-array option)
               (let* ([msg (recv (input "in"))]
                      [acc (recv (input "acc"))]
                      [sum (+ msg acc)])
                 (displayln sum)
                 (send (output "out") sum)
                 (send (output "acc") sum)
                 ))))
