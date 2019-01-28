#lang racket

(provide (contract-out
          [struct wallet ((name string?)
                          (view symbol?)
                          (addresses (listof string?))
                          (state-address symbol?)
			  )]))

(struct wallet (name
                view

                addresses
                state-address) #:prefab)
