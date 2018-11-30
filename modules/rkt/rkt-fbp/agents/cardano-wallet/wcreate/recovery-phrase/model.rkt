#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(define-agent
  #:input '("1" "2" "3" "next" "name") ; in array port
  #:output '("error" "next" "attach" "attach-blockchain" "out" "finalize") ; out port
  (define acc (try-recv (input "acc")))
  (unless acc
    (set! acc (vector #f #f #f "")))

  (define one (try-recv (input "1")))
  (when one
    (vector-set! acc 0 (cdr one)))

  (define two (try-recv (input "2")))
  (when two
    (vector-set! acc 1 (cdr two)))

  (define three (try-recv (input "3")))
  (when three
    (vector-set! acc 2 (cdr three)))

  (define name (try-recv (input "name")))
  (when name
    (vector-set! acc 3 name))

  (define next (try-recv (input "next")))
  (when next
    (if (vector-member #f acc)
        (send (output "error") '(set-label . "Please check every warning."))
        (begin
          (send (output "next") (cons 'display #t))
          (send (output "attach") (vector-ref acc 3))
          (send (output "attach-blockchain") "mainnet")
          (send (output "finalize") `(set-value . ,""))
          (send (output "finalize") `(display . #t))
          (send (output "out") `(add-wallet . ,(vector-ref acc 3))))))

  (send (output "acc") acc))
