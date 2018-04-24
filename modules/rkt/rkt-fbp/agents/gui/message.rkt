#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)


(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define (generate-message input)
  (lambda (frame)
    (let* ([msg (new message% [parent frame]
                     [auto-resize #t]
                     [label ""])])
      (send (input "acc") msg))))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out") ; out port
              #:proc (lambda (input output input-array output-array option)
                       (define acc (try-recv (input "acc")))
                       (define msg (recv (input "in")))
                       (define message (if acc
                                      acc
                                      (begin
                                        (send (output "out") (vector "init" (generate-message input)))
                                        (recv (input "acc")))))
                       (match msg
                         [(vector "set-label" new-label)
                          (class-send message set-label new-label)]
                         [else (send-action output output-array msg)])
                       (send (output "acc") message))))
