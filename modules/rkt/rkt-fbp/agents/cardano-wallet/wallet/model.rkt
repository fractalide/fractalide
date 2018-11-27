#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})

(define-agent
  #:input '("in") ; in array port
  #:output '("out" "update" "balance") ; out port
  (define msg (recv (input "in")))
  (define acc (try-recv (input "acc")))
  (match msg
    [(cons 'init w) #:when (wallet? w)
                         (set! acc w)
                         (send (output "update") (struct-copy wallet w))]
    [(cons 'set w)
     (set! acc w)
     (send (output "balance") (cons 'set-label (number->string (wallet-balance acc))))
     ]
    [else (send (output "out") msg)])
    (send (output "acc") acc))
