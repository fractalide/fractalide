#lang racket

(provide (contract-out
          [struct model ((wallets set?)
                         (id number?))]
          [struct wallet ((id number?)
                          (name string?)
                          (balance number?)
                          (addresses list?))]
          [model-add-wallet (-> model? wallet? void)]
          [model-rem-wallet (-> model? wallet? void)]))

(struct wallet (id name balance addresses) #:prefab)
(struct model (wallets id) #:prefab)

(define (model-add-wallet mdl wlt)
  (define next-id (+ 1 (model-id mdl)))
  (define new-wallet (struct-copy wallet wlt [id next-id]))
  (define new-model (struct-copy model mdl
                                 [wallets (set-add (model-wallets mdl) new-wallet)]
                                 [id next-id]))
  new-model)

(define (model-rem-wallet mdl wlt)
  (struct-copy model mdl [wallets (set-remove (model-wallets mdl) wlt)]))
