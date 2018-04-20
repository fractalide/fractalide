#lang racket/base

(provide (all-defined-out))

(require racket/match)

(struct graph (agent edge virtual-in virtual-out iip) #:prefab)
(struct g-agent (name type) #:prefab)
(struct g-edge (out port-out selection-out in port-in selection-in) #:prefab)
(struct g-virtual (virtual-agent virtual-port agent agent-port) #:prefab)
(struct g-iip (msg in port-in selection-in) #:prefab)

(struct add-agent (name type) #:prefab)
(struct connect (out out-port out-selection in in-port in-selection) #:prefab)
(struct iip (msg in in-port in-selection) #:prefab)
(struct virtual-in (name in in-port) #:prefab)
(struct virtual-out (name out out-port) #:prefab)


(define (make-graph actions)
  (for/fold ([acc (graph '() '() '() '() '())])
            ([act actions])
    (match act
      [(add-agent name type)
       (struct-copy graph acc [agent (cons (g-agent name type) (graph-agent acc))])]
      [(iip msg in in-p in-s)
       (struct-copy graph acc [iip (cons (g-iip msg in in-p in-s) (graph-iip acc))])]
      [(virtual-in name in in-port)
       (struct-copy graph acc [virtual-in (cons (g-virtual "" name in in-port) (graph-virtual-in acc))])]
      [(virtual-out name out out-port)
       (struct-copy graph acc [virtual-out (cons (g-virtual "" name out out-port) (graph-virtual-out acc))])]
      [(connect out out-p out-s in in-p in-s)
       (struct-copy graph acc [edge (cons (g-edge out out-p out-s in in-p in-s) (graph-edge acc))])]
      )))
