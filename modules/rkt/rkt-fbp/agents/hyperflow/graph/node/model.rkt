#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph)
         (prefix-in load: fractalide/modules/rkt/rkt-fbp/loader))
(require (rename-in racket/class [send class-send]))

(require/edge ${hyperflow.graph.node})

(define-agent
  #:input '("in" "get-path") ; in array port
  #:input-array '()
  #:output '("out" "pb" "circle" "text" "config" "get-path") ; out port
  #:output-array '("out" "line-start" "line-end")
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init (vector id x y name type?))
       (set! acc (node id (+ x 50) (+ y 50) name "" #f))
       (send (output "pb") (cons 'init (vector x y)))
       (send (output "text") (cons 'init (vector 10 35 name)))
       (send (output "config") (cons 'init (vector name)))
       (if type?
           ; True
           (set-type acc type? input output output-array)
           ; False
           (void))]
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
       (refresh output output-array acc)]
      [(cons 'select b)
       (send (output "config") (cons 'display b))]
      [(cons 'set-name name)
       (set-node-name! acc name)
       (send (output "text") (cons 'delete #t))
       (send (output "text") (cons 'init (vector 10 35 name)))
       (send (output "out") (cons 'set-name (vector (node-id acc) name)))]
      [(cons 'set-type type)
       (set! type (string-split type "fractalide/modules/rkt/rkt-fbp/"))
       (set! type (cadr type))
       ; set it
       (set-node-type! acc type)
       (send (output "out") (cons 'set-type (vector (node-id acc) type)))
       ; Get node information
       (define node #f)
       (define graph (load:load-graph type (lambda () #f)))
       (if graph
           (set! node graph)
           (set! node (load:load-agent type)))
       (set-node-raw! acc node)
       (refresh output output-array acc)]
      [else (send (output "out") msg)])
    (send (output "acc") acc))

(define (set-type acc type input output output-array)
  ; retrieve the type path
  (send (output "get-path") (graph:g-agent "" type))
  (define real-type (symbol->string (graph:g-agent-type (recv (input "get-path")))))
  ; set it
  (set-node-type! acc real-type)
  ; Get node information
  (define node #f)
  (define graph (load:load-graph (string->symbol real-type) (lambda () #f)))
  (if graph
      (set! node graph)
      (set! node (load:load-agent (string->symbol real-type))))
  (set-node-raw! acc node)
  (refresh output output-array acc))

(define (refresh output output-array acc)
  (sleep 0.05)
  (for ([(k v) (output-array "line-start")])
    (send v (cons 'move-line-start (cons (node-x acc) (node-y acc))))
    (if (node-raw acc)
        ; True : there is a type
        (if (graph:graph? (node-raw acc))
            ; true search for edge-in
            (send v (cons 'outport (cons "none" (graph:graph-virtual-out (node-raw acc)))))
            ; false search for input port
            (send v (cons 'outport (cons "none" (opt-agent-outport (node-raw acc))))))
        ; False : no type, send nothing
        #f))
  (for ([(k v) (output-array "line-end")])
    (send v (cons 'move-line-end (cons (node-x acc) (node-y acc))))
    (if (node-raw acc)
        ; True : there is a type
        (if (graph:graph? (node-raw acc))
            ; true search for edge-in
            (send v (cons 'inport (cons "none" (graph:graph-virtual-in (node-raw acc)))))
            ; false search for input port
            (send v (cons 'inport (cons "none" (opt-agent-inport (node-raw acc))))))
        ; False : no type, send nothing
        #f)))
