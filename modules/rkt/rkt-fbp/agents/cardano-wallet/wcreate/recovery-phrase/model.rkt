#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(define-agent
  #:input '("1" "2" "3" "next") ; in array port
  #:output '("error" "next") ; out port
  (define acc (try-recv (input "acc")))
  (unless acc
    (set! acc (vector #f #f #f)))

  (define one (try-recv (input "1")))
  (when one
    (vector-set! acc 0 (cdr one)))

  (define two (try-recv (input "2")))
  (when two
    (vector-set! acc 1 (cdr two)))

  (define three (try-recv (input "3")))
  (when three
    (vector-set! acc 2 (cdr three)))

  (define next (try-recv (input "next")))
  (when next
    (if (vector-member #f acc)
        (send (output "error") '(set-label . "Please check every warning."))
        (begin
          (send (output "next") (cons 'display #t))
          (send (output "error") '(set-label . "It's all for the moment!"))
          )))

  (send (output "acc") acc))
