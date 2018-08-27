#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${hyperflow.graph.line})

(define-agent
  #:input '("in") ; in array port
  #:input-array '()
  #:output '("out" "line" "from" "to") ; out port
  #:output-array '("out")
  (fun
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init (vector id x y x-end y-end))
       (set! acc (line id x y x-end y-end))
       (send (output "line") (cons 'init (vector x y x-end y-end)))]
      [(cons 'move-line-start (cons x y))
       (set! acc (struct-copy line acc [x x] [y y]))
       (redraw acc output)]
      [(cons 'move-line-end (cons x y))
       (set! acc (struct-copy line acc [x-end x] [y-end y]))
       (redraw acc output)]
      [(cons 'delete #t)
       (send (output "line") (cons 'delete #t))]
      [(cons 'inport inports)
       (send (output "to") (cons 'delete #t))
       (send (output "to") (cons 'init (list (cons 'label "To: ")
                                             (cons 'choices inports))))]
      [(cons 'outport outports)
       (send (output "from") (cons 'delete #t))
       (send (output "from") (cons 'init  (list (cons 'label "From: ")
                                                (cons 'choices outports))))]
      [(cons 'left-down event)
       (send (output "from") (cons 'display #t))]
      [(cons 'choice from)
       (send (output "out") (cons 'set-outport (vector (line-id acc) from)))]
      [(cons 'choice-outport to)
       (send (output "out") (cons 'set-inport (vector (line-id acc) to)))]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))

(define (redraw line output)
  (send (output "line") (cons 'delete #t))
  (send (output "line") (cons 'init (vector (line-x line)
                                            (line-y line)
                                            (line-x-end line)
                                            (line-y-end line)))))
