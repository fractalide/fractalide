#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))

(define agt (define-agent
              #:input '("in") ; in port
              #:output '("out" "halt") ; out port
              #:proc (lambda (input output input-array output-array option)
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
                         [(vector "init" curry) (curry fr)]
                         [(vector "close") (send (output "halt") #t)]
                         [else (display "msg: ") (displayln msg)])
                       (send (output "acc") fr))))
