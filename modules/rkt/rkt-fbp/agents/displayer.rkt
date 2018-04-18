#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (opt-agent
             '("in") ; in port
             '() ; in array port
             '("out") ; out port
             '() ; out array port
             (lambda (input output input-array output-array option)
               (define msg (recv (input "in")))
               (if option
                   (display option)
                   (void))
               (displayln msg)
               (send (output "out") msg))))
