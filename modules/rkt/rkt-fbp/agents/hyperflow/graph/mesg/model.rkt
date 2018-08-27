#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)
(require (rename-in racket/class [send class-send]))

(require/edge ${hyperflow.graph.mesg})

(define-agent
  #:input '("in") ; in array port
  #:input-array '()
  #:output '("out" "box" "config") ; out port
  #:output-array '("out" "line-start" "line-end")
  (fun
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init (vector id x y mesg?))
       (set! acc (mesg id (+ x 50) (+ y 50) ""))
       (send (output "box") (cons 'init (vector x y "./box.png")))
       (send (output "config") (cons 'init (list (cons 'label "Message:")
                                                 (cons 'init-value mesg?))))]
      [(cons 'move-to (vector x y drag?))
       (set! x (+ x 50))
       (set! y (+ y 50))
       (set-mesg-x! acc x)
       (set-mesg-y! acc y)
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'move-line-start (cons x y))))
       (for ([(k v) (output-array "line-end")])
         (send v (cons 'move-line-end (cons x y))))]
      [(cons 'right-down event)
       (send-action output output-array (cons 'build-edge (vector (mesg-id acc)
                                                                  (mesg-x acc)
                                                                  (mesg-y acc)
                                                                  (class-send event get-x)
                                                                  (class-send event get-y))))]
      [(cons 'is-deleted #t)
       (send-action output output-array (cons 'delete-mesg (mesg-id acc)))
       (send (output "circle") (cons 'delete #t))
       (send (output "config") (cons 'display #f))
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'delete #t)))
       (for ([(k v) (output-array "line-end")])
         (send v (cons 'delete #t)))]
      [(cons 'refresh #t)
       (sleep 0.05)
       (for ([(k v) (output-array "line-start")])
         (send v (cons 'move-line-start (cons (mesg-x acc) (mesg-y acc)))))]
      [(cons 'select b)
       (send (output "config") (cons 'display b))]
      [(cons 'text-field mesg)
       (set-mesg-mesg! acc mesg)
       (send (output "out") (cons 'set-mesg (vector (mesg-id acc) mesg)))]
      [(cons 'button event)
       (send (output "out") (cons 'start-mesg (mesg-id acc)))]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
