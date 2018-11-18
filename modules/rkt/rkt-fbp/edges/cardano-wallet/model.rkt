#lang racket

(provide (contract-out
          [struct model ((wallets wallet?))]
          [struct wallet ((name string?))]))

(struct wallet (name) #:prefab #:mutable)
(struct model (wallets) #:prefab #:mutable)
