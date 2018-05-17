#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out" "halt" "fvm") ; out port
              #:proc (lambda (input output input-array output-array)
                       (define acc (try-recv (input "acc")))
                       (define msg (recv (input "in")))
                       (define fr (if acc
                                         acc
                                         (let* ([new-es (make-eventspace)]
                                                [fr
                                                 (parameterize ([current-eventspace new-es])
                                                   (new frame% [label "Example"]))])
                                           (class-send fr show #t)
                                           fr)))
                       (match msg
                         [(cons 'init curry) (curry fr)]
                         [(cons 'dynamic-add _)
                          (send (output "fvm") msg)]
                         [(cons 'dynamic-remove graph)
                          (send (output "fvm") msg)]
                         [(cons 'close #t) (send (output "halt") #t) (send (output "fvm") (cons 'stop #t))]
                         [else (display "msg: ") (displayln msg)])
                       (send (output "acc") fr))))