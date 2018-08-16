#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)
(require (rename-in racket/class [send class-send]))

(require/edge ${hyperflow.graph.node})

(define-agent
  #:input '("in") ; in array port
  #:input-array '()
  #:output '("out" "circle" "config") ; out port
  #:output-array '("out" "line-start" "line-end")
  (fun
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init (vector id x y name))
       (set! acc (node id (+ x 50) (+ y 50) name))
       (send (output "circle") (cons 'init (vector x y "./circle.png")))
       (send (output "config") (cons 'init (vector name)))]
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
       (send-action output output-array (cons 'build-edge (vector (node-id acc)
                                                                  (node-x acc)
                                                                  (node-y acc)
                                                                  (class-send event get-x)
                                                                  (class-send event get-y))))]
      [(cons 'is-deleted #t)
       (send-action output output-array (cons 'delete-node (node-id acc)))
       (send (output "circle") (cons 'delete #t))
       (send (output "config") (cons 'display #f))
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'delete #t)))
       (for ([(k v) (output-array "line-end")])
         (send v (cons 'delete #t)))]
      [(cons 'refresh #t)
       (sleep 0.05)
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'move-line-start (cons (node-x acc) (node-y acc)))))]
      [(cons 'select b)
       (send (output "config") (cons 'display b))]
      [(cons 'set-name name)
       (set-node-name! acc name)]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
