#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/scheduler
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/agent
         (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph))

(define sched (make-scheduler #f))
(sched (msg-add-agent "sched" "agents/fvm/scheduler.rkt"))
(sched (msg-add-agent "load-graph" "agents/fvm/load-graph.rkt"))
(sched (msg-add-agent "get-graph" "agents/fvm/get-graph.rkt"))
(sched (msg-add-agent "get-path" "agents/fvm/get-path.rkt"))
(sched (msg-add-agent "fvm" "agents/fvm/fvm.rkt"))
(sched (msg-add-agent "halt" "agents/halter.rkt"))
(sched (msg-connect "fvm" "sched" "sched" "in"))
(sched (msg-connect "fvm" "flat" "load-graph" "in"))
(sched (msg-connect "fvm" "halt" "halt" "in"))
(sched (msg-connect "load-graph" "out" "fvm" "flat"))
(sched (msg-connect "load-graph" "ask-graph" "get-graph" "in"))
(sched (msg-connect "get-graph" "out" "load-graph" "ask-graph"))
(sched (msg-connect "load-graph" "ask-path" "get-path" "in"))
(sched (msg-connect "get-path" "out" "load-graph" "ask-path"))

(sched (msg-iip "sched" "acc" (make-scheduler #f)))
(sched (msg-iip "halt" "in" #f))

(define path (vector-ref (current-command-line-arguments) 0))
(define a-graph (graph:make-graph (graph:node "main" path)))

(sched (msg-iip "fvm" "in" (vector "add" a-graph)))
(sched (msg-iip "fvm" "in" "stop"))
(sched (msg-stop))
