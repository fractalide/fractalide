#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/scheduler)

(define g (make-graph
           (node "sched" "fvm/scheduler")
           (node "load-graph" "fvm/load-graph")
           (node "get-graph" "fvm/get-graph")
           (node "get-path" "fvm/get-path")
           (node "fvm" "fvm/fvm")
           (node "halt" "halter")
           (edge "fvm" "sched" #f "sched" "in" #f)
           (edge "fvm" "flat" #f "load-graph" "in" #f)
           (edge "fvm" "halt" #f "halt" "in" #f)
           (edge "load-graph" "out" #f "fvm" "flat" #f)
           (edge "load-graph" "ask-graph" #f "get-graph" "in" #f)
           (edge "get-graph" "out" #f "load-graph" "ask-graph" #f)
           (edge "load-graph" "ask-path" #f "get-path" "in" #f)
           (edge "get-path" "out" #f "load-graph" "ask-path" #f)

           (iip "sched" "acc" (make-scheduler #f))
           (iip "halt" "in" #f)

           (virtual-in "in" "fvm" "in")))
