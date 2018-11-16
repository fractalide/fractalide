#lang racket

(provide (contract-out
          [struct wcreate ((name string?)
                           (pwd string?)
                           (pwd-cfm string?))]))

(struct wcreate (name pwd pwd-cfm) #:prefab #:mutable)
