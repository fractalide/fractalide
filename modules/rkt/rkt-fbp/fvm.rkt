#lang racket

(require fractalide/modules/rkt/rkt-fbp/scheduler
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/agent
         (prefix-in graph: fractalide/modules/rkt/rkt-fbp/graph))

(provide call-with-new-fvm-and-scheduler
         fbp-agents-string->symbol
         setup-fvm)

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
  (sched (msg-connect "fvm" "sched" "sched" "in")
         (msg-connect "fvm" "flat" "load-graph" "in")
         (msg-connect "fvm" "halt" "halt" "in")
         (msg-connect "load-graph" "out" "fvm" "flat")
         (msg-connect "load-graph" "ask-graph" "get-graph" "in")
         (msg-connect "get-graph" "out" "load-graph" "ask-graph")
         (msg-connect "load-graph" "ask-path" "get-path" "in")
         (msg-connect "get-path" "out" "load-graph" "ask-path")))

(define (call-with-new-fvm-and-scheduler f)
  (define fvm-sched (make-scheduler #f))
  (setup-fvm fvm-sched)
  (define sched (make-scheduler #f))
  (fvm-sched (msg-mesg "sched" "acc" sched))
  (fvm-sched (msg-mesg "halt" "in" #f))
  (f fvm-sched sched)
  (fvm-sched (msg-mesg "fvm" "in" (cons 'stop #t)))
  (fvm-sched (msg-stop)))

(module+ main
  (call-with-new-fvm-and-scheduler (lambda (fvm-sched sched)
    (define path (vector-ref (current-command-line-arguments) 0))
    (define a-graph (graph:make-graph (graph:node "main" path)))
    (fvm-sched (msg-mesg "fvm" "in" (cons 'add a-graph))))))
