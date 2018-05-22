#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)

(define (maybe-nix-string->module-path-or-passthrough type)
  (cond
    ; Fully processed, ready for dynamic-require
    [((or/c module-path? resolved-module-path? module-path-index?) type) type]
    ; Needs processing, transform into relative path
    [(equal? (substring type 0 2) "${")
     (define dot-path (regexp-match #px"\\$\\{(.*)\\}" type))
     (string-append "agents/"
                    (string-trim
                      (string-replace (cadr dot-path) "." "/")) ".rkt")]
    [else
     (raise-argument-error 'get-path
                           "type required to be a nix interpolation string or something recognized by dynamic-require"
                           type)]))

(define agt
  (define-agent
    #:input '("in")
    #:output '("out")
    #:proc
    (lambda (input output input-array output-array)
      (let* ([agt (recv (input "in"))])
        (define new-type (maybe-nix-string->module-path-or-passthrough (g-agent-type agt)))
        (define new-agent (struct-copy g-agent agt
                                       [type new-type]))
        (send (output "out") new-agent)))))
