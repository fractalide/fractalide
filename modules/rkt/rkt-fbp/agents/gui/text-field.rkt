#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)


(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define (generate-text-field input)
  (lambda (frame)
    (let* ([text-field (new text-field% [parent frame]
                     [label #f]
                     [callback (lambda (t-f event)
                                 (send (input "in") (vector (class-send event get-event-type)
                                                            (class-send t-f get-value))))])])
      (send (input "acc") text-field))))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out") ; out port
              #:output-array '("out")
              #:proc (lambda (input output input-array output-array option)
                       (define acc (try-recv (input "acc")))
                       (define msg (recv (input "in")))
                       (define text-f (if acc
                                          acc
                                          (begin
                                            (send (output "out") (vector "init" (generate-text-field input)))
                                            (recv (input "acc")))))
                       (match msg
                         [(vector "set-label" new-label)
                          (class-send text-f set-label new-label)]
                         [else (send-action output output-array msg)])
                       (send (output "acc") text-f))))
