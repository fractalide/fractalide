#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${cardano-wallet.model})
(require/edge ${fvm.dynamic-add})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
  (define msg (recv (input "in")))
  (define acc (try-recv (input "acc")))
  (match msg
    [(cons 'init w) #:when (wallet? w)
    ;(when acc
      ; (dynamic-remove
      ;   (make-graph
      ;   (node "delete" ${cardano-wallet.wsettings.delete.delete}))
      ;   input output))
     (send-dynamic-add
      (make-graph
       (node "delete" ${cardano-wallet.wsettings.delete.delete})
       (mesg "delete-wallet-name" "in" `(init . ((label . ,(string-append "Retype the wallet name \"" (wallet-name w) "\" to confirm deletion"))))))
      input output)
     (set! acc w)]
    [(cons 'check-box b)
     (when acc
       (send-dynamic-add
        (make-graph
         (mesg "delete-wallet-name" "in" `(display . ,b)))
        input output))]
    [(cons 'text-field t)
     (when acc
       (define e (equal? t (wallet-name acc)))
       (send-dynamic-add
        (make-graph
         (mesg "delete-confirm-button" "in" `(set-enabled . ,e)))
        input output))]
    [(cons 'confirm #t)
     (when acc
      (send-dynamic-add
       (make-graph
        (mesg "delete-destroy" "name" (wallet-name acc)))
       input output)
       (send (output "out") '(delete . #t))
       (dynamic-remove
         (make-graph
         (node "delete" ${cardano-wallet.wsettings.delete.delete}))
         input output)
       (send (output "out") `(delete-wallet . ,acc))
       (set! acc #f))]
    [else (send (output "out") msg)])
  (send (output "acc") acc))
