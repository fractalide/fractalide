#lang racket

(require fractalide/modules/rkt/rkt-fbp/def)

(provide (contract-out
          [struct write ((path path-string?)
                         (mode (or/c 'binary 'text))
                         (exists	(or/c 'error 'append 'update 'replace 'truncate 'truncate/replace)))]
          [make-write (->* (path-string?)
                           ((or/c 'binary 'text)
                            (or/c 'error 'append 'update 'replace 'truncate 'truncate/replace))
                           write?)]))

(struct write (path mode exists) #:prefab)

(define (make-write path [mode 'binary] [exists 'error])
  (write path mode exists))
