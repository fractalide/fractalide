#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/graph)
(require (prefix-in g: graph)
         json)

(define-agent
  #:input '("in") ; in port
  #:output '("out" "acc") ; out port
  (fun
   (define msg (recv (input "in")))

   ; Convert fractalide/graph -> g:graph
   (define g (g:directed-graph '()))
   (for ([agt (graph-agent msg)])
         (g:add-vertex! g (g-agent-name agt)))
   (for ([edg (graph-edge msg)])
     (g:add-directed-edge! g (g-edge-out edg) (g-edge-in edg)))
   (for ([in (graph-virtual-in msg)])
     (g:add-directed-edge! g
                         (string-append (g-virtual-virtual-port in)
                                        (g-virtual-agent in)
                                        (g-virtual-agent-port in))
                         (g-virtual-agent in)))
   (for ([out (graph-virtual-out msg)])
     (g:add-directed-edge! g
                         (g-virtual-agent out)
                         (string-append (g-virtual-agent out)
                                        (g-virtual-agent-port out)
                                        (g-virtual-virtual-port out))))
   (for ([mesg (graph-mesg msg)])
     (g:add-directed-edge! g
                         ; TODO: possibility to have several mesg towards the same ports
                         (string-append "msg" (g-mesg-in mesg) (g-mesg-port-in mesg))
                         (g-mesg-in mesg)))

   ; Retrieve the position
   (define opt-graph (string-split (g:graphviz g) "digraph G {"))
   (set! opt-graph (string-append
                    "digraph G { node [shape=circle, width=1];
                                 rankdir=LR;"
                    (car opt-graph)))
   (define raw-json
     (let ([out (open-output-string)]
           [dot-file (make-temporary-file "graph~a.dot")])
       (parameterize ([current-output-port out]
                      [current-error-port out])
         (display-to-file opt-graph dot-file #:exists 'replace)
         (system (format "dot -Tjson ~a" dot-file))
       (get-output-string out))))
   (define json (string->jsexpr raw-json))

   ; Send the new graph
   (define objects (hash-ref json 'objects))
   (define nodes (make-hash))
   (for ([obj objects])
     (define pos (hash-ref obj 'pos #f))
     (if pos
         ; True, display
         (begin
           (hash-set! nodes (hash-ref obj 'label) pos)
           ; (send (output "out") (cons 'add-node (vector (string->number (car pos))
                                                        ; (string->number (cadr pos))
                                                        ; (hash-ref obj 'name))))
           )
         ; False, do nothing
         (void)))

   (for ([agt (graph-agent msg)])
     (define pos (string-split (hash-ref nodes (g-agent-name agt)) ","))
     (send (output "out") (cons 'add-node (vector (string->number (car pos))
                                                  (string->number (cadr pos))
                                                  (substring (g-agent-name agt) 1)
                                                  (g-agent-type agt)))))
   (for ([msg (graph-mesg msg)])
     (define pos (string-split (hash-ref nodes (string-append "msg" (g-mesg-in msg) (g-mesg-port-in msg))) ","))
     (send (output "out") (cons 'add-mesg (vector (string->number (car pos))
                                                  (string->number (cadr pos))
                                                  (g-mesg-mesg msg)
                                                  (substring (g-mesg-in msg) 1)
                                                  (g-mesg-port-in msg)))))

   (for ([edg (graph-edge msg)])
     (send (output "out") (cons 'add-edge (vector (substring (g-edge-out edg) 1)
                                                  (g-edge-port-out edg)
                                                  (g-edge-selection-out edg)
                                                  (substring (g-edge-in edg) 1)
                                                  (g-edge-port-in edg)
                                                  (g-edge-selection-in edg)))))

   (send (output "acc") msg)))
