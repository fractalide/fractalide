#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (opt-agent
             '() ; in port
             '() ; in array port
             '() ; out port
             '() ; out array port
             (lambda (input output input-array output-array option)
               (displayln "I'm dummy, I do nothing!"))))
