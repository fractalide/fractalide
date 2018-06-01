#lang racket

(require fractalide/modules/rkt/rkt-fbp/scheduler
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/agent
         (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph))

(provide setup-fvm fbp-agents-string->symbol)

(define (fbp-agents-string->symbol agent-relative-path)
  (string->symbol (string-append "fractalide/modules/rkt/rkt-fbp/agents/"
                                 agent-relative-path)))

(define (setup-fvm sched)
  (for ([name+agent '(("sched" "fvm/scheduler")
                      ("load-graph" "fvm/load-graph")
                      ("get-graph" "fvm/get-graph")
                      ("get-path" "fvm/get-path")
                      ("fvm" "fvm/fvm")
                      ("halt" "halter"))])
    (match-define (list name agent) name+agent)
    (sched (msg-add-agent name (fbp-agents-string->symbol agent))))
  (sched (msg-connect "fvm" "sched" "sched" "in"))
  (sched (msg-connect "fvm" "flat" "load-graph" "in"))
  (sched (msg-connect "fvm" "halt" "halt" "in"))
  (sched (msg-connect "load-graph" "out" "fvm" "flat"))
  (sched (msg-connect "load-graph" "ask-graph" "get-graph" "in"))
  (sched (msg-connect "get-graph" "out" "load-graph" "ask-graph"))
  (sched (msg-connect "load-graph" "ask-path" "get-path" "in"))
  (sched (msg-connect "get-path" "out" "load-graph" "ask-path")))

(module+ main
  (define sched (make-scheduler #f))
  (setup-fvm sched)
  (sched (msg-mesg "sched" "acc" (make-scheduler #f)))
  (sched (msg-mesg "halt" "in" #f))
  (define path (vector-ref (current-command-line-arguments) 0))
  (define a-graph (graph:make-graph (graph:node "main" path)))
  (sched (msg-mesg "fvm" "in" (cons 'add a-graph)))
  (sched (msg-mesg "fvm" "in" (cons 'stop #t)))
  (sched (msg-stop)))