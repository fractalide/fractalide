#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)

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

(define a-graph (make-graph (list
                             (add-agent "nand" "agents/fvm/nand.rkt")
                             (add-agent "and" "agents/fvm/and.fbp")
                             (add-agent "disp" "agents/displayer.rkt")
                             (connect "and" "res" #f "disp" "in" #f)
                             (connect "nand" "res" #f "and" "in" #f)
                             (iip #t "and" "in" #f))))
(sched (msg-iip "load-graph" "in" a-graph))

(sched (msg-add-agent "fvm/scheduler" "sched"))
(sched (msg-iip "sched" "acc" (make-scheduler #f)))
(sched (msg-iip "sched" "in" (msg-add-agent "displayer" "disp")))
(sched (msg-iip "sched" "in" (msg-iip "disp" "in" "hello from a new scheduler!")))
(sched (msg-iip "sched" "in" (msg-stop)))

(sched (msg-stop))
