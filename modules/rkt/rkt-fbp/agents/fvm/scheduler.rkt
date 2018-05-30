#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require fractalide/modules/rkt/rkt-fbp/def)

(require racket/match)

(define-agent
  #:input '("in")
  #:output '("out")
  (fun
   (let* ([sched (recv (input "acc"))]
          [msg (recv (input "in"))])
     (sched msg)
     (send (output "acc") sched))
   ))
