#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (opt-agent
             '("in") ; in port
             '() ; in array port
             '("out") ; out port
             '() ; out array port
             (lambda (input output input-array output-array)
               (define msg (recv (input "in")))
               (display "msg received: ")
               (displayln msg)
               (send (output "out") msg))))
