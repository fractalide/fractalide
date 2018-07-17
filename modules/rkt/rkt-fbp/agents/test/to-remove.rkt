#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "remove" ${plumbing.option-transform})
  (mesg "remove" "option" (lambda (_) '(remove . #t)))
  (edge-in "in" "remove" "in")
  (edge-out "remove" "out" "out"))
