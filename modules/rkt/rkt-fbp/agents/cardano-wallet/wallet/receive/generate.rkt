#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         simple-qr racket/runtime-path racket/draw)

(require/edge ${cardano-wallet.model})
(define-runtime-path qr-path "./qrcode.png")
(define-runtime-path blank-qr-path "./baconipsum.png")

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

  (if (string-contains? res "Invalid")
      (let ([qr (read-bitmap blank-qr-path)])
        (send (output "qr") `(set-label . ,qr)))
      (let ([new-w (struct-copy wallet opt [addresses (cons res (wallet-addresses opt))])]
            [qr (read-bitmap qr-path)])
        ; Add the res in the wallet
        (send (output "out") (cons 'update-wallet new-w))
        ; Display
        (qr-write res qr-path)
        (send (output "qr") `(set-label . ,qr))))

  ; Quick display
  (send (output "address") `(set-label . ,res)))
