#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)

(define (interpolated-by-nix? type)
  (define dot-path (regexp-match #px"\\$\\{(.*)\\}" type))
  (if (equal? (substring type 0 2) "${")
      ; it's not interpolated nix code
      (string-append "agents/"
                     (string-trim
                      (string-replace (cadr dot-path) "." "/")) ".rkt")
      ; nix has interpolated it, use the path as is
      type))

(define agt
  (define-agent
    #:input '("in")
    #:output '("out")
    #:proc
    (lambda (input output input-array output-array)
      (let* ([agt (recv (input "in"))])
        (define new-type (interpolated-by-nix? (g-agent-type agt)))
        (define new-agent (struct-copy g-agent agt
                                       [type new-type]))
        (send (output "out") new-agent)))))
