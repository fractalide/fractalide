#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         racket/match)

(define agt (define-agent
              #:input '("in")
              #:output '("out")
              #:output-array '("out")
              #:proc (lambda (input output input-array output-array option)
                       (let* ([acc (try-recv (input "acc"))]
                              [msg (recv (input "in"))])
                         (define new-acc (if acc acc
                                             (let ([g (make-graph
                                                       (node "hp" "gui/horizontal-panel")
                                                       (virtual-out "out" "hp" "out"))])
                                               (dynamic-add g input output)
                                               0)))
                         (match msg
                           [(vector 'button)
                            (let* ([name (string-append "dynamic" (number->string new-acc))])
                              (define g (make-graph
                                         (node name option)
                                         (edge name "out" #f "hp" "place" new-acc)))
                              (dynamic-add g input output))]
                           [else (send-action output output-array msg)])
                         (send (output "acc") (+ new-acc 1))))))
