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
       (set! acc (raw-graph (g:directed-graph '()) #f 0 0))
       (send-dynamic-add
        (make-graph
         (node "pb" ${gui.pasteboard})
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
         (edge name "out" _ "pb" "snip" id)
         (mesg name "in" (cons 'init (vector x y name))))
        input output)]
      [(cons 'build-edge (vector name n-x n-y m-x m-y))
       (define actual (raw-graph-build-edge acc))
       (cond
         [(eq? actual #f)
          (define id (+ 1 (length (g:get-edges (raw-graph-graph acc)))))
          (define edge-name (format "edge~a" id))
          (set-raw-graph-build-edge-id! acc id)
          (set-raw-graph-build-edge! acc name)
          (send-dynamic-add
           (make-graph
            (node edge-name ${hyperflow.graph.line})
            (edge edge-name "out" _ "pb" "place" id)
            (mesg edge-name "in" (cons 'init (vector n-x n-y m-x m-y)))
            (edge name "line-start" id edge-name "in" _))
           input output)]
         [(eq? actual name)
          (define id (raw-graph-build-edge-id acc))
          (define edge-name (format "edge~a" id))
          (set-raw-graph-build-edge! acc #f)
          (send-dynamic-add
           (make-graph
            (mesg edge-name "in" (cons 'delete #t)))
           input output)
          (dynamic-remove
           (make-graph
            (node edge-name ${hyperflow.graph.line})
            (edge edge-name "out" _ "pb" "place" id)
            (edge name "line-start" id edge-name "in" _))
           input output)
          ]
         [else
          (define id (raw-graph-build-edge-id acc))
          (define edge-name (format "edge~a" id))
          (send-dynamic-add
           (make-graph
            (edge name "line-end" id edge-name "in" _)
            (mesg edge-name "in" (cons 'move-line-end (cons n-x n-y))))
           input output)
          (set-raw-graph-build-edge! acc #f)
          (g:add-edge! (raw-graph-graph acc) actual name)])
       ]
      [(cons 'motion event)
       (if (eq? #f (raw-graph-build-edge acc))
           void
           (let* ((id (+ 1 (length (g:get-edges (raw-graph-graph acc)))))
                 (edge-name (format "edge~a" id)))
             (send-dynamic-add
              (make-graph
               (mesg edge-name "in" (cons 'move-line-end (cons (class-send event get-x)
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
       ;TODO
       void]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))
