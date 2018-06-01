#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/fvm)
(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph))

(module+ main
  (define sched (make-scheduler #f))
  (setup-fvm sched)
  (sched (msg-mesg "sched" "acc" (make-scheduler #f)))
  (sched (msg-mesg "halt" "in" #f))
  (define path (fbp-agents-string->symbol "hyperflow/run"))
  (define a-graph (graph:make-graph (graph:node "main" path)))
  (sched (msg-mesg "fvm" "in" (cons 'add a-graph)))
  (sched (msg-mesg "fvm" "in" (cons 'stop #t)))
  (sched (msg-stop)))
