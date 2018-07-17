#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "close" ${plumbing.option-transform})
  (mesg "close" "option" (lambda (_) '(close . #t)))
  (edge-in "in" "close" "in")
  (edge-out "close" "out" "out"))
