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
       (set! acc (raw-graph g (make-hash) #f 0))
       (send-dynamic-add
        (make-graph
         (node "vp" ${gui.vertical-panel})

         (node "pb" ${gui.pasteboard})
         (edge "pb" "out" _ "vp" "place" 1)

         (node "ph-config" ${gui.place-holder})
         (edge "ph-config" "out" _ "vp" "place" 2)
         (mesg "ph-config" "in" (cons 'set-stretchable-height #f))

         (node "preload-node" ${hyperflow.graph.node})
         (node "building-edge" ${hyperflow.graph.line})
         (edge "building-edge" "out" _ "pb" "place" "0")
         (edge-out "vp" "out" "dynamic-out")
         (mesg "pb" "in" (cons 'init #t)))
        input output)]
      [(cons 'add-node (vector x y))
       (define id (+ 1 (length (g:get-vertices (raw-graph-graph acc)))))
       (define name (format "node~a" id))
       (g:add-vertex! (raw-graph-graph acc) id)
       (hash-set! (raw-graph-nodes acc) name (g-agent name #f))
       (send-dynamic-add
        (make-graph
         (node name ${hyperflow.graph.node})
         (edge name "out" _ "pb" "snip" name)
         (edge name "config" _ "ph-config" "place" name)
         (mesg name "in" (cons 'init (vector name x y name))))
        input output)]
      [(cons 'add-mesg (vector x y))
       (define id (+ 1 (length (g:get-vertices (raw-graph-graph acc)))))
       (define name (format "mesg~a" id))
       (g:add-vertex! (raw-graph-graph acc) id)
       (hash-set! (raw-graph-nodes acc) name (g-mesg #f #f #f))
       (send-dynamic-add
        (make-graph
         (node name ${hyperflow.graph.mesg})
         (edge name "out" _ "pb" "snip" name)
         (edge name "config" _ "ph-config" "place" name)
         (mesg name "in" (cons 'init (vector name x y))))
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
            (mesg name "in" (cons 'refresh #t))
            (edge name "line-end" edge-name edge-name "in" _)
            (edge edge-name "config" _ "ph-config" "place" edge-name))
           input output)
          (set-raw-graph-build-edge! acc #f)
          (g:add-directed-edge! (raw-graph-graph acc) actual name)
          (hash-set! (raw-graph-nodes acc) edge-name (g-edge
                                                      (string-append actual "-typed") #f #f
                                                      (string-append name "-typed") #f #f))])]
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
           (if (class-send event get-control-down)
               ; Add a Mesg
               (send (input "in") (cons 'add-mesg (vector (- (class-send event get-x) 50)
                                                          (- (class-send event get-y) 50))))
               ; Add a Node
               (send (input "in") (cons 'add-node (vector (- (class-send event get-x) 50)
                                                          (- (class-send event get-y) 50))))
               )
           void)
       (set-raw-graph-last-click! acc new)]
      [(cons 'delete-node name)
       (delete-node acc name input output)]
      [(cons 'set-name (vector id name))
       (define actual (hash-ref (raw-graph-nodes acc) id))
       (hash-set! (raw-graph-nodes acc) id (struct-copy g-agent actual [name name]))]
      [(cons 'set-type (vector id type))
       (define actual (hash-ref (raw-graph-nodes acc) id))
       (if (g-agent-type actual)
           ; True: there is a node running, need to remove edges and the node, then recreate.
           ;TODO : it's all the hotswapping feature...
           (void)
           ; False: do nothing
           (void))
       (hash-set! (raw-graph-nodes acc) id (struct-copy g-agent actual [type type]))
       (send-dynamic-add
        (make-graph
         (node (string-append id "-typed") type))
        input output)
       ]
      [(cons 'set-mesg (vector id mesg))
       (hash-set! (raw-graph-nodes acc) id (g-mesg #f #f mesg))]
      [(cons 'start-mesg id)
       (define msg (hash-ref (raw-graph-nodes acc) id))
       (set! msg (g-mesg-mesg msg))
       (define edges (g:get-neighbors (raw-graph-graph acc) id))
       (for ([edge edges])
         (define edge-name (string-append "edge-" id "-" edge))
         (define edg (hash-ref (raw-graph-nodes acc) edge-name))
         (send-dynamic-add
          (make-graph
           (mesg (string-append edge "-typed") (g-edge-port-in edg) msg))
          input output)
         )]
      [(cons 'set-inport (vector id port))
       (define actual (hash-ref (raw-graph-nodes acc) id))
       (hash-set! (raw-graph-nodes acc) id (struct-copy g-edge actual [port-in port]))
       (manage-edge id actual acc input output)]
      [(cons 'set-outport (vector id port))
       (define actual (hash-ref (raw-graph-nodes acc) id))
       (hash-set! (raw-graph-nodes acc) id (struct-copy g-edge actual [port-out port]))
       (manage-edge id actual acc input output)]
      [else (send (output "out") msg)])
    (send (output "acc") acc)
    ))

(define (manage-edge id old acc input output)
  (define splited (string-split id "-"))
  ; Remove if already exists
  (displayln (g-edge-port-in old))
  (displayln (g-edge-port-out old))
  (displayln (g-edge-out old))
  (displayln (g-edge-in old))
  (if (and (g-edge-port-in old) (g-edge-port-out old))
      ; True - disconnect
      (begin
        (displayln "DisConnect!")
        (dynamic-remove
         (make-graph
          (edge (g-edge-out old) (g-edge-port-out old) _ (g-edge-in old) (g-edge-port-in old) _))
         input output)
        )
      ; False - Nothing
      (void))

  ; Add if bind
  (define actual (hash-ref (raw-graph-nodes acc) id))
  (if (and (g-edge-port-in actual) (g-edge-port-out actual))
      ; True - connect
      (begin
        (displayln "Connect!")
        (send-dynamic-add
         (make-graph
          (edge (g-edge-out actual) (g-edge-port-out actual) _ (g-edge-in actual) (g-edge-port-in actual) _))
         input output))
      ; False - Nothing
      (void)))

(define (delete-node acc name input output)
  (define edges (g:get-edges (raw-graph-graph acc)))
  (set! edges (filter (lambda (edge)
                        (cond
                          [(string=? name (car edge)) #t]
                          [(string=? name (cadr edge)) #t]
                          [else #f]))
                      edges))
  (for ([e edges])
    (define edge-name (string-append "edge-" (car e) "-" (cadr e)))
    (define edg (hash-ref (raw-graph-nodes acc) edge-name))
    (hash-remove! (raw-graph-nodes acc) edge-name)
    (dynamic-remove
     (make-graph
      (node edge-name ${hyperflow.graph.line})
      (edge (car e) "line-start" edge-name edge-name "in" _)
      (edge (cadr e) "line-end" edge-name edge-name "in" _)
      (edge edge-name "config" _ "ph-config" "place" edge-name)
      (edge (g-edge-out edg) (g-edge-port-out edg) (g-edge-selection-out edg)
            (g-edge-in edg) (g-edge-port-in edg) (g-edge-selection-in edg)))
     input output)
    )
  (dynamic-remove
   (make-graph
    (node name ${hyperflow.graph.node})
    (edge name "config" _ "ph-config" "place" name)
    (edge name "out" _ "pb" "snip" name))
   input output)
  (g:remove-vertex! (raw-graph-graph acc) name)
  (hash-remove! (raw-graph-nodes acc) name))
