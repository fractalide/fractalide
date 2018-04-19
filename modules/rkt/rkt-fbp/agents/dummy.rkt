#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt (define-agent
              #:proc (lambda (input output input-array output-array option)
                       (displayln "I'm dummy, I do nothing!"))))
