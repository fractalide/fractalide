#lang racket/base

(provide (all-defined-out))

(require racket/match
         (prefix-in agt: fractalide/modules/rkt/rkt-fbp/agent)
         fractalide/modules/rkt/rkt-fbp/def)

(struct graph (agent edge virtual-in virtual-out mesg) #:prefab)
(struct g-agent (name type) #:prefab)
(struct g-edge (out port-out selection-out in port-in selection-in) #:prefab)
(struct g-virtual (virtual-agent virtual-port agent agent-port) #:prefab)
(struct g-mesg (in port-in mesg) #:prefab)

(struct node (name type) #:prefab)
(struct edge (out out-port out-selection in in-port in-selection) #:prefab)
(struct mesg (in in-port msg) #:prefab)
(struct virtual-in (name in in-port) #:prefab)
(struct virtual-out (name out out-port) #:prefab)

(define make-graph
  (lambda actions
    (for/fold ([acc (graph '() '() '() '() '())])
              ([act actions])
      (match act
        [(node name type)
         (struct-copy graph acc [agent (cons (g-agent name type) (graph-agent acc))])]
        [(mesg in in-p msg)
         (struct-copy graph acc [mesg (cons (g-mesg in in-p msg) (graph-mesg acc))])]
        [(virtual-in name in in-port)
         (struct-copy graph acc [virtual-in (cons (g-virtual "" name in in-port) (graph-virtual-in acc))])]
        [(virtual-out name out out-port)
         (struct-copy graph acc [virtual-out (cons (g-virtual "" name out out-port) (graph-virtual-out acc))])]
        [(edge out out-p out-s in in-p in-s)
         (struct-copy graph acc [edge (cons (g-edge out out-p out-s in in-p in-s) (graph-edge acc))])]
        ))))

; TODO duplicate code in dynamic-add and dynamic-remove
(define (dynamic-remove delta input output)
  (define name (port-name (input "in")))
  ; rename to be unique
  ; agent
  (define new-agent (for/list ([agt (graph-agent delta)])
                      (struct-copy g-agent agt [name (string-append name "-" (g-agent-name agt))])))
  ; edge
  (define new-edge (for/list ([edg (graph-edge delta)])
                     (struct-copy g-edge edg [out (string-append name "-" (g-edge-out edg))]
                                  [in (string-append name "-" (g-edge-in edg))])))
  ; mesg
  (define new-mesg (for/list ([i (graph-mesg delta)])
                    (struct-copy g-mesg i [in (string-append name "-" (g-mesg-in i))])))
  ; virtual out - in
  (define new-v-in (for/list ([vi (graph-virtual-in delta)])
                     (struct-copy g-virtual vi [virtual-agent (string-append name "-" (g-virtual-virtual-agent vi))]
                                  [agent (string-append name "-" (g-virtual-agent vi))])))
  (define new-v-out (for/list ([vo (graph-virtual-out delta)])
                      (struct-copy g-virtual vo [virtual-agent (string-append name "-" (g-virtual-virtual-agent vo))]
                                   [agent (string-append name "-" (g-virtual-agent vo))])))
  (define new-delta (graph new-agent new-edge new-v-in new-v-out new-mesg))
  ; send the differences
  (agt:send (output "out") (cons 'dynamic-remove new-delta)))

  ; used to indicate that we don't care about out-selection and in-port selection
  (define _ #f)
