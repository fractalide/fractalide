#lang racket

(provide (contract-out
          [struct wallet ((name string?)
			  )]))

(struct wallet (name) #:prefab #:mutable)
