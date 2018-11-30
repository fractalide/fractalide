#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         simple-qr racket/runtime-path racket/draw)

(require/edge ${cardano-wallet.model})
(define-runtime-path qr-path "./qrcode.png")

(define-agent
  #:input '("passwd" "res") ; in array port
  #:output '("out" "name" "passwd" "account-index" "address-index" "address" "qr") ; out port
  (define passwd (recv (input "passwd")))
  (define opt (recv (input "option")))

  (send (output "name") (wallet-name opt))
  ; TODO : check for these two numbers!
  (send (output "account-index") "0")
  (send (output "address-index") (number->string (random 10000)))
  (send (output "passwd") passwd)

  (define res (recv (input "res")))
  ; Add the res in the wallet
  (define new-w (struct-copy wallet opt [addresses (cons res (wallet-addresses opt))]))

  ; Quick display
  (send (output "address") `(set-label . ,res))
  (qr-write res qr-path)
  (define qr (read-bitmap qr-path))
  (send (output "qr") `(set-label . ,qr))

  (send (output "out") (cons 'update-wallet new-w))
  )
