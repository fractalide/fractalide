#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/scheduler)

(define-graph
  (node "sched" "${fvm.scheduler}")
  (node "load-graph" "${fvm.load-graph}")
  (node "get-graph" "${fvm.get-graph}")
  (node "get-path" "${fvm.get-path}")
  (node "fvm" "${fvm.fvm}")
  (node "halt" "${halter}")
  (edge "fvm" "sched" _ "sched" "in" _)
  (edge "fvm" "flat" _ "load-graph" "in" _)
  (edge "fvm" "halt" _ "halt" "in" _)
  (edge "load-graph" "out" _ "fvm" "flat" _)
  (edge "load-graph" "ask-graph" _ "get-graph" "in" _)
  (edge "get-graph" "out" _ "load-graph" "ask-graph" _)
  (edge "load-graph" "ask-path" _ "get-path" "in" _)
  (edge "get-path" "out" _ "load-graph" "ask-path" _)

  (mesg "sched" "acc" (make-scheduler _))
  (mesg "halt" "in" _)

  (edge-in "in" "fvm" "in"))
