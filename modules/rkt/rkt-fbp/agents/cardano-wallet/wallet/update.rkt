#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (define msg (recv (input "in")))
  (define cli-path (find-executable-path "cardano-cli"))
  (unless cli-path (error "'cardano-cli' not found on PATH"))
  (define raw (with-output-to-string (lambda ()
                                       (unless (system* cli-path "wallet" "status" (wallet-name msg))
                                       (error "Call to wallet status failed.")))))
  (define x (cadr (string-split raw "balance")))
  (define y (car (string-split x "\n")))
  (define z (substring y 2))
  (set-wallet-balance! msg (string->number z))
  (send (output "out") (cons 'set msg)))

