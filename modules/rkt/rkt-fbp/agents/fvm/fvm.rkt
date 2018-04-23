#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/graph)
(require fractalide/modules/rkt/rkt-fbp/def)

(require racket/match)

(define agt (define-agent
              #:input '("in" "flat") ; in port
              #:output '("sched" "flat" "out" "halt") ; out port
              #:proc (lambda (input output input-array output-array option)
                       (let* ([msg (recv (input "in"))])
                         (match msg
                           [(vector "add" add)
                            ; Flat the graph
                            (send (output "flat") add)
                            (define add-flat (recv (input "flat")))
                            ; Add the agent
                            (for ([agent (graph-agent add-flat)])
                              (send (output "sched") (msg-add-agent (g-agent-name agent) (g-agent-type agent))))
                            (for ([edge (graph-edge add-flat)])
                              (match edge
                                [(g-edge out p-out #f in p-in #f)
                                 (send (output "sched") (msg-connect out p-out in p-in))]
                                [(g-edge out p-out s-out in p-in #f)
                                 (send (output "sched") (msg-connect-array-to out p-out s-out in p-in))]
                                [(g-edge out p-out #f in p-in s-in)
                                 (send (output "sched") (msg-connect-to-array out p-out in p-in s-in))]
                                [(g-edge out p-out s-out in p-in s-in)
                                 (send (output "sched") (msg-connect-array-to-array out p-out s-out in p-in s-in))]))
                            (for ([iip (graph-iip add-flat)])
                              (match iip
                                [(g-iip in p-in iip)
                                 (send (output "sched") (msg-iip in p-in iip))]))]
                           ["stop"
                            (send (output "halt") #t)
                            (send (output "sched") (msg-stop))])))))
