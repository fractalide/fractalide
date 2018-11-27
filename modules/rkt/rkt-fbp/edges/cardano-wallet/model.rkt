#lang racket

(provide (contract-out
          [struct model ((wallets set?)
                         (id number?))]
          [struct wallet ((id number?)
                          (name string?)
                          (balance number?))]
          [model-add-wallet! (-> model? wallet? void)]
          [model-rem-wallet! (-> model? wallet? void)]))

(struct wallet (id name balance) #:prefab #:mutable)
(struct model (wallets id) #:prefab #:mutable)

(define (model-add-wallet! model wallet)
  (define next-id (+ 1 (model-id model)))
  (set-wallet-id! wallet next-id)
  (set-model-wallets! model (set-add (model-wallets model) wallet))
  (set-model-id! model next-id))

(define (model-rem-wallet! model wallet)
  (set-model-wallets! model (set-remove (model-wallets model) wallet)))
