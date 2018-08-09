#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

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
       (set! acc (node x y name))
       (send (output "circle") (cons 'init (vector x y "./circle.png")))]
      [(cons 'move-to (vector x y drag?))
       (set! x (+ x 50))
       (set! y (+ y 50))
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'move-line-start (cons x y))))
       (for ([(k v) (output-array "line-end")])
         (send v (cons 'move-line-end (cons x y))))
       ]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
