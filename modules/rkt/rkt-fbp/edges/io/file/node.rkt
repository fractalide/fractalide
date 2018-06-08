#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct node ((type path-string?)
                        (mode (or/c 'binary 'text))
                        (exists	(or/c 'error 'append 'update 'replace 'truncate 'truncate/replace)))]))

(struct write (path mode exists) #:prefab)
(define new-write ((path [mode 'binary] [exists 'error]))
  )
