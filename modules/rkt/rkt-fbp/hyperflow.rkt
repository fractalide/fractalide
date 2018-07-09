#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/fvm)
(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph))

(module+ main
  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (fbp-agents-string->symbol "hyperflow/run"))
    (define a-graph (graph:make-graph (graph:node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
