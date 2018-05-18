#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)


(define agt
  (define-agent
    #:input '("in")
    #:output '("out")
    #:proc
    (lambda (input output input-array output-array)
      (let* ([agt (recv (input "in"))]
             [name (g-agent-name agt)]
             [type (g-agent-type agt)])
        ; retrieve the graph struct
        (define g (dynamic-require type 'g))
        ; rename the subgraph
        (let ([new-agent
               (for/list ([agent (graph-agent g)])
                 (struct-copy g-agent agent [name (string-append name "-" (g-agent-name agent))]))]
              [new-edge
               (for/list ([edge (graph-edge g)])
                 (struct-copy g-edge edge [out (string-append name "-" (g-edge-out edge))]
                              [in (string-append name "-" (g-edge-in edge))]))]
              [new-virtual-in
               (for/list ([in (graph-virtual-in g)])
                 (struct-copy g-virtual in [virtual-agent name]
                              [agent (string-append name "-" (g-virtual-agent in))]))]
              [new-virtual-out
               (for/list ([out (graph-virtual-out g)])
                 (struct-copy g-virtual out [virtual-agent name]
                              [agent (string-append name "-" (g-virtual-agent out))]))]
              [new-mesg
               (for/list ([mesg (graph-mesg g)])
                 (struct-copy g-mesg mesg [in (string-append name "-" (g-mesg-in mesg))]))])
          (send (output "out") (graph new-agent new-edge new-virtual-in new-virtual-out new-mesg)))))))
