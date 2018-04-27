#lang racket/base

(provide (all-defined-out))

(require racket/match)

(struct graph (agent edge virtual-in virtual-out iip) #:prefab)
(struct g-agent (name type) #:prefab)
(struct g-edge (out port-out selection-out in port-in selection-in) #:prefab)
(struct g-virtual (virtual-agent virtual-port agent agent-port) #:prefab)
(struct g-iip (in port-in iip) #:prefab)

(struct agent (name type) #:prefab)
(struct edge (out out-port out-selection in in-port in-selection) #:prefab)
(struct iip (in in-port msg) #:prefab)
(struct virtual-in (name in in-port) #:prefab)
(struct virtual-out (name out out-port) #:prefab)

(define make-graph
  (lambda actions
    (for/fold ([acc (graph '() '() '() '() '())])
              ([act actions])
      (match act
        [(agent name type)
         (struct-copy graph acc [agent (cons (g-agent name type) (graph-agent acc))])]
        [(iip in in-p msg)
         (struct-copy graph acc [iip (cons (g-iip in in-p msg) (graph-iip acc))])]
        [(virtual-in name in in-port)
         (struct-copy graph acc [virtual-in (cons (g-virtual "" name in in-port) (graph-virtual-in acc))])]
        [(virtual-out name out out-port)
         (struct-copy graph acc [virtual-out (cons (g-virtual "" name out out-port) (graph-virtual-out acc))])]
        [(edge out out-p out-s in in-p in-s)
         (struct-copy graph acc [edge (cons (g-edge out out-p out-s in in-p in-s) (graph-edge acc))])]
        ))))
