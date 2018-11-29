#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})
(require/edge ${fvm.dynamic-add})

(define-agent
  #:input '("in") ; in array port
  #:output '("out" "test") ; out port
  (define msg (recv (input "in")))
  (define acc (try-recv (input "acc")))
  (match msg
    [(cons 'init #t)
     (set! acc (model (set) 0))
     (send-dynamic-add
      (make-graph
       (node "tab" ${gui.tab-panel})
       (edge-out "tab" "out" "dynamic-out"))
      input output)
     (send (output "test") (struct-copy model acc))]
    [(cons 'set msg)
     (change-wallet acc msg input output)
     (set! acc msg)]
    [(cons 'update-wallet new-w)
     (define new-wallets (list->set (set-map (model-wallets acc)
                                             (lambda(w)
                                               (if (eq? (wallet-id w) (wallet-id new-w))
                                                   (begin
                                                     (send-dynamic-add
                                                      (make-graph
                                                       (mesg (wallet-name new-w) "in" (cons 'set new-w)))
                                                      input output)
                                                     new-w)
                                                   w)))))
     (set! acc (struct-copy model acc
                            [wallets new-wallets]))]
    [else (send (output "out") msg)])
    (send (output "acc") acc))

(define (change-wallet old new input output)
  (define added (set-subtract (model-wallets new) (model-wallets old)))
  (define deleted (set-subtract (model-wallets old) (model-wallets new)))
  (for ([i deleted])
    (define name (wallet-name i))
    (dynamic-remove
     (make-graph
      (node name ${cardano-wallet.wallet})
      (edge name "out" _ "tab" "place" (string-append (number->string (wallet-id i)) ";" name)))
     input output))
  (for ([i added])
    (define name (wallet-name i))
    (send-dynamic-add
     (make-graph
      (node name ${cardano-wallet.wallet})
      (edge name "out" _ "tab" "place" (string-append (number->string (wallet-id i)) ";" name))
      (mesg name "in" (cons 'init (struct-copy wallet i)))
      )
     input output)))

(define (get-wallet-name wallet)
  (string-append (wallet-name wallet) (number->string (wallet-id wallet))))
