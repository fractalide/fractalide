#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "display" ${displayer})
  (node "delay" ${delayer})
  (edge "delay" "out" _ "display" "in" _)
  (mesg "delay" "in" "Hello you!")
  (mesg "display" "in" "For the test")
  )
