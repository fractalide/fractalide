#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)
(require (rename-in racket/class [send class-send]))

(require (prefix-in g: graph))
(require/edge ${hyperflow.graph})
(require/edge ${io.file.write})
(require/edge ${fvm.dynamic-add})

(define-agent
  #:input '("in") ; in array port
  #:input-array '()
  #:output '("out") ; out port
  #:output-array '()
  (fun
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init #t)
       (define g (g:directed-graph '()))
       (set! acc (raw-graph g #f 0 0))
       (send-dynamic-add
        (make-graph
         (node "pb" ${gui.pasteboard})
         (node "preload-node" ${hyperflow.graph.node})
         (node "building-edge" ${hyperflow.graph.line})
         (edge "building-edge" "out" _ "pb" "place" "0")
         (edge-out "pb" "out" "dynamic-out")
         (mesg "pb" "in" (cons 'init #t)))
        input output)]
      [(cons 'add-node (vector x y))
       (define id (+ 1 (length (g:get-vertices (raw-graph-graph acc)))))
       (define name (format "node~a" id))
       (g:add-vertex! (raw-graph-graph acc) id)
       (send-dynamic-add
        (make-graph
         (node name ${hyperflow.graph.node})
         (edge name "out" _ "pb" "snip" name)
         (mesg name "in" (cons 'init (vector x y name))))
        input output)]
      [(cons 'build-edge (vector name n-x n-y m-x m-y))
       (define actual (raw-graph-build-edge acc))
       (cond
         [(eq? actual #f)
          (send-dynamic-add
           (make-graph
            (mesg "building-edge" "in" (cons 'init (vector "building-edge" n-x n-y m-x m-y)))
            (edge name "line-start" 0 "building-edge" "in" _))
           input output)
          (set-raw-graph-build-edge! acc name)]
         [(eq? actual name)
          (set-raw-graph-build-edge! acc #f)
          (send-dynamic-add
           (make-graph
            (mesg "building-edge" "in" (cons 'delete #t)))
           input output)
          (dynamic-remove
           (make-graph
            (edge name "line-start" 0 "building-edge" "in" _))
           input output)
          ]
         [else
          ; Remove the building edge
          (send-dynamic-add
           (make-graph
            (mesg "building-edge" "in" (cons 'delete #t)))
           input output)
          (dynamic-remove
           (make-graph
            (edge actual "line-start" 0 "building-edge" "in" _))
           input output)
          ; Add the new one
          (define edge-name (string-append "edge-" actual "-" name))
          (send-dynamic-add
           (make-graph
            (node edge-name ${hyperflow.graph.line})
            (edge edge-name "out" _ "pb" "place" edge-name)
            (mesg edge-name "in" (cons 'init (vector edge-name n-x n-y n-x n-y)))
            (edge actual "line-start" edge-name edge-name "in" _)
            (mesg actual "in" (cons 'refresh #t))
            (edge name "line-end" edge-name edge-name "in" _))
           input output)
          (set-raw-graph-build-edge! acc #f)
          (g:add-directed-edge! (raw-graph-graph acc) actual name)])
       ]
      [(cons 'motion event)
       (if (eq? #f (raw-graph-build-edge acc))
           void
           (begin
           (send-dynamic-add
            (make-graph
             (mesg "building-edge" "in" (cons 'move-line-end (cons (class-send event get-x)
                                                                   (class-send event get-y)))))
            input output)))
       ]
      [(cons 'left-down event)
       (define new (class-send event get-time-stamp))
       (define delta (- new (raw-graph-last-click acc)))
       (if (and (> delta 0) (> 250 delta))
           (send (input "in") (cons 'add-node (vector (- (class-send event get-x) 50)
                                                      (- (class-send event get-y) 50))))
           void)
       (set-raw-graph-last-click! acc new)]
      [(cons 'delete-node name)
       (define edges (g:get-edges (raw-graph-graph acc)))
       (set! edges (filter (lambda (edge)
                             (cond
                               [(string=? name (car edge)) #t]
                               [(string=? name (cadr edge)) #t]
                               [else #f]))
                           edges))
       (for ([e edges])
         (define edge-name (string-append "edge-" (car e) "-" (cadr e)))
         (dynamic-remove
          (make-graph
           (node edge-name ${hyperflow.graph.line})
           (edge (car e) "line-start" edge-name edge-name "in" _)
           (edge (cadr e) "line-end" edge-name edge-name "in" _))
          input output)
         )
       (dynamic-remove
        (make-graph
         (node name ${hyperflow.graph.node})
         (edge name "out" _ "pb" "snip" name))
        input output)
       (g:remove-vertex! (raw-graph-graph acc) name)
       ]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
