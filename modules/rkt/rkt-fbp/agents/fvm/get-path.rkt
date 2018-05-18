#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)

(define (interpolated-by-nix? type)
  (if (equal? (substring type 0 2) "${")
      ; it's uninterpolated nix code, remove the ${ and } and send it as is
      (string-append "agents/" (substring type 2 (- (string-length type) 1))  ".rkt")
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
