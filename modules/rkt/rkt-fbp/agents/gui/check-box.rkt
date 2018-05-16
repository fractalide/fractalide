#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match)
(require (prefix-in class: racket/class))

(define (generate-cb input)
  (lambda (frame)
    (let* ([cb (class:new (with-event check-box% input) [parent frame]
                       [label "Check box"]
                       [callback (lambda (cb event)
                                   (send (input "in") (cons 'check-box (class:send cb get-value))))])])
      (send (input "acc") cb))))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out") ; out port
              #:output-array '("out")
              #:proc (lambda (input output input-array output-array)
                       (define acc (try-recv (input "acc")))
                       (define msg (recv (input "in")))
                       (define cb (if acc
                                      acc
                                      (begin
                                        (send (output "out") (cons 'init (generate-cb input)))
                                        (recv (input "acc")))))
                       (define managed #f)
                       (set! managed (area-manage cb msg output output-array))
                       (set! managed (subarea-manage cb msg output output-array))
                       (set! managed (window-manage cb msg output output-array))
                       (if managed
                           (void)
                           (match msg
                             [(cons 'get-value act)
                              (send-action output output-array (cons act (class:send cb get-value)))]
                             [(cons 'set-value b)
                              (class:send cb set-value b)]
                             [else (send-action output output-array msg)])
                           )
                       (send (output "acc") cb))))
