#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(struct graph (agent edge virtual-in virtual-out iip) #:prefab)
(struct g-agent (name type) #:prefab)
(struct g-edge (out port-out selection-out in port-in selection-in) #:prefab)
(struct g-virtual (virtual-agent virtual-port agent agent-port) #:prefab)
(struct g-iip (msg in port-in selection-in) #:prefab)

(define agt (define-agent
              #:input '("in")
              #:output '("out")
              #:proc (lambda (input output input-array output-array option)
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
                               [new-iip
                                (for/list ([iip (graph-iip g)])
                                  (struct-copy g-iip iip [in (string-append name "-" (g-iip-in iip))]))])
                           (send (output "out") (graph new-agent new-edge new-virtual-in new-virtual-out new-iip)))))))
