#lang racket/base

(provide agt)

(require racket/list)
(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)

; (-> agent graph)
(define (get-graph agent input output)
  (send (output "ask-graph") agent)
  (recv (input "ask-graph")))

; (-> (Listof virtual) (Listof virtual) graph graph)
; TODO : one pass over the edges for optimization
(define (resolve-virtual virtual-in virtual-out actual-graph)
  ; virtual-in resolve
  (define new-edge
    (if (empty? virtual-in)
        (graph-edge actual-graph)
        (for*/fold
            ([acc '()])
            ([edg (graph-edge actual-graph)]
             [virt virtual-in])
          (if (and (string=? (g-edge-in edg) (g-virtual-virtual-agent virt))
                   (string=? (g-edge-port-in edg) (g-virtual-virtual-port virt)))
              (cons (struct-copy g-edge edg [in (g-virtual-agent virt)][port-in (g-virtual-agent-port virt)]) acc)
              (cons edg acc)))))
  ; virtual out-resolve
  (define res-edge
    (if (empty? virtual-out)
        new-edge
        (for*/fold
            ([acc '()])
            ([edg new-edge]
             [virt virtual-out])
          (if (and (string=? (g-edge-out edg) (g-virtual-virtual-agent virt))
                   (string=? (g-edge-port-out edg) (g-virtual-virtual-port virt)))
              (cons (struct-copy g-edge edg [out (g-virtual-agent virt)][port-out (g-virtual-agent-port virt)]) acc)
              (cons edg acc)))))
  ; Iip resolve
  (define res-iip
    (if (empty? virtual-in)
        (graph-iip actual-graph)
        (for*/fold
            ([acc '()])
            ([iip (graph-iip actual-graph)]
             [virt virtual-in])
          (if (and (string=? (g-iip-in iip) (g-virtual-virtual-agent virt))
                   (string=? (g-iip-port-in iip) (g-virtual-virtual-port virt)))
              (cons (struct-copy g-iip iip [in (g-virtual-agent virt)] [port-in (g-virtual-agent-port virt)]) acc)
              (cons iip acc)))))
  (struct-copy graph actual-graph [edge res-edge] [iip res-iip])
  )

; (- (Listof agent) graph String graph)
(define (flat-graph actual-graph input output)
  (define (rec-flat-graph not-visited virtual-in virtual-out actual-graph)
    (if (empty? not-visited)
        (resolve-virtual virtual-in virtual-out actual-graph)
        (let* ([next (car not-visited)]
               [next (begin (send (output "ask-path") next) (recv (input "ask-path")))]
               [is-subnet? (dynamic-require (g-agent-type next) 'g (lambda () #f))])
          (if is-subnet?
              ; It's a sub-graph. Get the new graph, add the nodes in not-visited, save the virtual port and save the rest of the graph
              (let* ([new-graph (get-graph next input output)]
                     ; Add the agents in the not-visited list
                     [new-not-visited (append (graph-agent new-graph) (cdr not-visited))]
                     ; add the virtual port
                     [new-virtual-in (append (graph-virtual-in new-graph) virtual-in)]
                     [new-virtual-out (append (graph-virtual-out new-graph) virtual-out)]
                     ; add the iips
                     [new-iip (append (graph-iip new-graph) (graph-iip actual-graph))]
                     ; add the edges
                     [new-edge (append (graph-edge new-graph) (graph-edge actual-graph))])
                (rec-flat-graph new-not-visited new-virtual-in new-virtual-out
                                (struct-copy graph actual-graph [iip new-iip][edge new-edge])))
              ; It's a normal agent, do nothing and go for the next
              (rec-flat-graph (cdr not-visited) virtual-in virtual-out (struct-copy graph actual-graph [agent (cons next (graph-agent actual-graph))]))))))
  (rec-flat-graph (graph-agent actual-graph) '() '() (struct-copy graph actual-graph [agent '()])))

(define agt (define-agent
              #:input '("in" "ask-path" "ask-graph")
              #:output '("out" "ask-path" "ask-graph")
              #:proc (lambda (input output input-array output-array option)
                       (let* ([msg (recv (input "in"))])
                         (define flat (flat-graph msg input output))
                         (send (output "out") flat)))))
