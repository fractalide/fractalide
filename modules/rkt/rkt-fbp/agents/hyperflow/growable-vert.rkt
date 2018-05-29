#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         racket/match)

(require fractalide/modules/rkt/rkt-fbp/edges/fvm/dynamic-add)

(define agt
  (define-agent
    #:input '("in")
    #:output '("out" "label")
    #:output-array '("out")
    #:proc
    (lambda (input output input-array output-array)
      (let* ([acc (try-recv (input "acc"))]
             [option (recv (input "option"))]
             [msg (recv (input "in"))])
        ; If there is not yet an acc, it is the first run. We spawn a vertical-panel in the frame.
        (define new-acc (if acc acc
                            (let ([g (make-graph
                                      (node "vp" "${gui.vertical-panel}")
                                      (mesg "vp" "in" '(set-alignment . (center . bottom)))
                                      (edge-out "vp" "out" "dynamic-out"))])
                              (send-dynamic-add g input output)
                              0)))
        (match msg
          ; We want to add a node given as option, and connect it to the previous vertical-panel
          [(cons 'add init-mesg)
           (let* ([name (string-append "dynamic" (number->string new-acc))]
                  [name-hp (string-append name "-hp")]
                  [name-but (string-append name "-but")]
                  [name-set (string-append name "-set")])
             (define g (make-graph
                        ; main hp
                        (node name-hp "${gui.horizontal-panel}")
                        (edge name-hp "out" _ "vp" "place" new-acc)
                        ; The button
                        (node name-but "${gui.button}")
                        (edge name-but "out" _ name-hp "place" 2)
                        (mesg name-but "in" '(init . ((label . "x"))))
                        ;   The delete msg
                        (node name-set "${mesg.set-ip}")
                        (mesg name-set "option"
                              (cons 'remove (number->string new-acc)))
                        (edge name-but "out" 'button name-set "in" _)
                        (edge-out name-set "out" "dynamic-out")
                        ; The unknown widget
                        (node name option)
                        (edge name "out" #f name-hp "place" 1)
                        (mesg name "in" init-mesg)))
             (send-dynamic-add g input output))
           (send (output "label") '(set-value . ""))
           (set! new-acc (+ new-acc 1))]
          ; We want to remove the last node added
          [(cons 'remove place)
           (let* ([name (string-append "dynamic" place)]
                  [name-hp (string-append name "-hp")]
                  [name-but (string-append name "-but")]
                  [name-set (string-append name "-set")])
             (send-dynamic-add (make-graph
                                (mesg name "in" (cons 'delete #t))
                                (mesg name-hp "in" (cons 'delete #t)))
                               input output)
             ; TODO: remove this sleep : iip to array input port to send delete in the "vp"?
             (sleep 0.2)
             ; remove the actual nodes
             (define g (make-graph
                        (edge name-hp "out" _ "vp" "place" (string->number place))
                        (node name-hp "${gui.horizontal-panel}")
                        (node name-but "${gui.button}")
                        (node name-set "${mesg.set-ip}")
                        (node name option)
                        (edge-out name-set "out" "dynamic-out")
                        ))
             (dynamic-remove g input output))]
          [else (send-action output output-array msg)])
        (send (output "acc") new-acc)))))
