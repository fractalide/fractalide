#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/scheduler
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/agent
         (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph))

(define sched (make-scheduler #f))
(define path (vector-ref (current-command-line-arguments) 0))
(define a-graph (graph:make-graph (graph:node "main" path)))

(sched (msg-add-agent "sched" "agents/fvm/scheduler.rkt")
       (msg-add-agent "load-graph" "agents/fvm/load-graph.rkt")
       (msg-add-agent "get-graph" "agents/fvm/get-graph.rkt")
       (msg-add-agent "get-path" "agents/fvm/get-path.rkt")
       (msg-add-agent "fvm" "agents/fvm/fvm.rkt")
       (msg-add-agent "halt" "agents/halter.rkt")
       (msg-connect "fvm" "sched" "sched" "in")
       (msg-connect "fvm" "flat" "load-graph" "in")
       (msg-connect "fvm" "halt" "halt" "in")
       (msg-connect "load-graph" "out" "fvm" "flat")
       (msg-connect "load-graph" "ask-graph" "get-graph" "in")
       (msg-connect "get-graph" "out" "load-graph" "ask-graph")
       (msg-connect "load-graph" "ask-path" "get-path" "in")
       (msg-connect "get-path" "out" "load-graph" "ask-path")

       (msg-mesg "sched" "acc" (make-scheduler #f))
       (msg-mesg "halt" "in" #f)

       (msg-mesg "fvm" "in" (cons 'add a-graph))
       (msg-mesg "fvm" "in" (cons 'stop #t))
       (msg-stop))
