#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define (generate-button input)
  (lambda (frame)
    (let* ([but (new button% [parent frame]
                       [label "Click here"]
                       [callback (lambda (button event)
                                   (send (input "in") (cons (class-send event get-event-type) #t)))])])
      (send (input "acc") but))))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out") ; out port
              #:output-array '("out")
              #:proc (lambda (input output input-array output-array option)
                       (define acc (try-recv (input "acc")))
                       (define msg (recv (input "in")))
                       (define btn (if acc
                                      acc
                                      (begin
                                        (send (output "out") (cons 'init (generate-button input)))
                                        (recv (input "acc")))))
                       (define managed #f)
                       (set! managed (area-manage btn msg output output-array))
                       (set! managed (subarea-manage btn msg output output-array))
                       (set! managed (window-manage btn msg output output-array))
                       (if managed
                           (void)
                           (send-action output output-array msg))
                       (send (output "acc") btn))))
