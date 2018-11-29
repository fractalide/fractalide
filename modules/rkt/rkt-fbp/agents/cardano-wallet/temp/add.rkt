#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (define msg (recv (input "in")))
  ;(define new-model (model-add-wallet msg (wallet 0 "denis" 0 (list))))

  (define cli-path (find-executable-path "cardano-cli"))
  (unless cli-path (error "'cardano-cli' not found on PATH"))

  (define raw (with-output-to-string (lambda ()
                                       (unless (system* cli-path "wallet" "list")
                                         (error "Call to wallet list failed.")))))

  (define new-model (foldl
                     ;fun
                     (lambda (el acc)
                       (model-add-wallet acc (wallet 0 el 0 (list))))
                     ;init
                     msg
                     ;list
                     (string-split raw "\n")))

  (send (output "out") (cons 'set new-model)))

