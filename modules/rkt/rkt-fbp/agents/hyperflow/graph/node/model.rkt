#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)
(require (rename-in racket/class [send class-send]))

(require/edge ${hyperflow.graph.node})

(define-agent
  #:input '("in") ; in array port
  #:input-array '()
  #:output '("out" "circle") ; out port
  #:output-array '("out" "line-start" "line-end")
  (fun
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init (vector x y name))
       (set! acc (node (+ x 50) (+ y 50) name))
       (send (output "circle") (cons 'init (vector x y "./circle.png")))]
      [(cons 'move-to (vector x y drag?))
       (set! x (+ x 50))
       (set! y (+ y 50))
       (set-node-x! acc x)
       (set-node-y! acc y)
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'move-line-start (cons x y))))
       (for ([(k v) (output-array "line-end")])
         (send v (cons 'move-line-end (cons x y))))]
      [(cons 'right-down event)
       (send-action output output-array (cons 'build-edge (vector (node-name acc)
                                                                  (node-x acc)
                                                                  (node-y acc)
                                                                  (class-send event get-x)
                                                                  (class-send event get-y))))]
      [(cons 'is-deleted #t)
       (send-action output output-array (cons 'delete-node (node-name acc)))]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
