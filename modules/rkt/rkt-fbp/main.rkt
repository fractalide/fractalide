#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/agent)

(define sched (make-scheduler #f))
(sched (msg-add-agent "fvm/load-graph" "load-graph"))
(sched (msg-add-agent "fvm/get-graph" "get-graph"))
(sched (msg-connect "load-graph" "ask-graph" "get-graph" "in"))
(sched (msg-connect "get-graph" "out" "load-graph" "ask-graph"))

(sched (msg-add-agent "fvm/nand" "nand"))
(sched (msg-add-agent "displayer" "disp"))
(sched (msg-connect "nand" "res" "disp" "in"))
(sched (msg-iip "nand" "x" #t))
(sched (msg-iip "nand" "y" #t))

(struct graph (agent edge virtual-in virtual-out iip) #:prefab)
(struct g-agent (name type) #:prefab)
(struct g-edge (out port-out selection-out in port-in selection-in) #:prefab)
(struct g-virtual (virtual-agent virtual-port agent agent-port) #:prefab)
(struct g-iip (msg in port-in selection-in) #:prefab)

(sched (msg-iip "load-graph" "in" (graph (list (g-agent "nand" "agents/fvm/nand.rkt")
                                               (g-agent "and" "agents/fvm/and.fbp")
                                               (g-agent "disp" "agents/displayer.rkt"))
                                         (list
                                          (g-edge "and" "res" #f "disp" "in" #f)
                                          (g-edge "nand" "res" #f "and" "in" #f)
                                          (g-edge "disp" "out" #f "nand" "x" #f))
                                         '()
                                         '()
                                         '())))

(sched (msg-stop))
