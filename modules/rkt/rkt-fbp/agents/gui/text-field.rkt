#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define (generate-text-field input)
  (lambda (frame)
    (let* ([text-field (new (with-event text-field% input) [parent frame]
                     [label #f]
                     [callback (lambda (t-f event)
                                 (send (input "in") (cons (class-send event get-event-type)
                                                            (class-send t-f get-value))))])])
      (send (input "acc") text-field))))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out") ; out port
              #:output-array '("out")
              #:proc (lambda (input output input-array output-array)
                       (define acc (try-recv (input "acc")))
                       (define msg (recv (input "in")))
                       (define text-f (if acc
                                          acc
                                          (begin
                                            (send (output "out") (cons 'init (generate-text-field input)))
                                            (recv (input "acc")))))
                       (define managed #f)
                       (set! managed (area-manage text-f msg output output-array))
                       (set! managed (subarea-manage text-f msg output output-array))
                       (set! managed (window-manage text-f msg output output-array))
                       (if managed
                           (void)
                           (send-action output output-array msg))
                       (send (output "acc") text-f))))
