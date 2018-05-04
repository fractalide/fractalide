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
                         ; If there is not yet an acc, it is the first run. We spawn a vertical-panel in the frame.
                         (define new-acc (if acc acc
                                             (let ([g (make-graph
                                                       (node "vp" "gui/vertical-panel")
                                                       (virtual-out "dynamic-out" "vp" "out"))])
                                               (dynamic-add g input output)
                                               0)))
                         (match msg
                           ; We want to add a node given as option, and connect it to the previous vertical-panel
                           [(vector 'button)
                            (let* ([name (string-append "dynamic" (number->string new-acc))])
                              (define g (make-graph
                                         (node name option)
                                         (edge name "out" #f "vp" "place" new-acc)))
                              (dynamic-add g input output))
                            (set! new-acc (+ new-acc 1))]
                           ; We want to remove the last node added
                           [(vector "remove")
                            ; Don't remove if there is nothing to remove...
                            (if (> new-acc 0)
                                ; true, remove
                                (begin
                                  (set! new-acc (- new-acc 1))
                                  (let* ([name (string-append "dynamic" (number->string new-acc))])
                                    ; send delete to vp
                                    (dynamic-add (make-graph (iip name "in" (vector "delete"))) input output)
                                    ; remove the actual nodes
                                    (define g (make-graph
                                               (node name option)
                                               (edge name "out" #f "vp" "place" new-acc)))
                                    (dynamic-remove g input output)))
                                ; false, do nothing
                                (void))]
                           [else (send-action output output-array msg)])
                         (send (output "acc") new-acc)))))
