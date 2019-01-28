#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         simple-qr racket/runtime-path racket/draw)

(require/edge ${cantor.wallet})
(define-runtime-path qr-path "./qrcode.png")
(define-runtime-path blank-qr-path "./baconipsum.png")

(define-agent
  #:input '("in" "res") ; in array port
  #:output '("out" "name" "passwd" "account-index" "address-index" "address" "qr") ; out port
  (define msg (recv (input "in")))
  (define pwd (car msg))
  (define wlt (cdr msg))

  (send (output "name") (wallet-name wlt))
  ; TODO : check for these two numbers!
  (send (output "account-index") (number->string (random 10000)))
  (send (output "address-index") (number->string (random 10000)))
  (send (output "passwd") pwd)

  (define res (recv (input "res")))

  (if (string-contains? res "Invalid")
      (let ([new-w (struct-copy wallet wlt [state-address 'wrong-pwd])])
        (send (output "out") `(wallet . ,new-w)))
      (let ([new-w (struct-copy wallet wlt
                                [addresses (cons res (wallet-addresses wlt))]
                                [state-address 'new])])
        ; Add the res in the wallet
        (qr-write res qr-path)
        (send (output "out") (cons 'wallet new-w)))))
