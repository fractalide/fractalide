#lang racket

(require fractalide/modules/rkt/rkt-fbp/def
         (prefix-in agt: fractalide/modules/rkt/rkt-fbp/agent)
         fractalide/modules/rkt/rkt-fbp/graph)

(provide
 send-dynamic-add
 (contract-out
          [struct dynamic-add ((graph graph?) (sender port?))]))

(struct dynamic-add (graph sender) #:prefab)

(define (send-dynamic-add delta input output)
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
  (agt:send (output "out") (cons 'dynamic-add (dynamic-add new-delta (input "in")))))
