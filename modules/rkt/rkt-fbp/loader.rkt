#lang racket/base

(provide load-agent dynamic-require-agent)

(define (dynamic-require-agent agt provided (fail-thunk #f))
  (define (try-dynamic-require mod provided fail-thunk fallback)
    (with-handlers
      ([exn:fail:filesystem:missing-module? fallback])
      (if fail-thunk (dynamic-require mod provided fail-thunk)
                     (dynamic-require mod provided))))
  (if (symbol? agt)
      (try-dynamic-require agt provided fail-thunk (lambda (e)
        (try-dynamic-require (string->symbol (string-append
          "fractalide/modules/rkt/rkt-fbp/agents/"
          (symbol->string agt)))
          provided fail-thunk (lambda (_) (raise e)))))
      (try-dynamic-require agt provided fail-thunk (lambda (e) (raise e)))))

(define (load-agent path) (dynamic-require-agent path 'agt))
