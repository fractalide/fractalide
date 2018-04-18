#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (opt-agent
             '() ; in port
             '("in") ; in array port
             '("out") ; out port
             '() ; out array port
             (lambda (input output input-array output-array)
                 (define sum (for/fold ([sum 0])
                                       ([(k v) (input-array "in")])
                               (+ sum (recv v))))
                 (send (output "out") sum))))
