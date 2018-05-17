#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph
           (node "panel" "gui/horizontal-panel")
           (mesg "panel" "in" (cons 'set-orientation #f))
           (virtual-in "in" "panel" "in")
           (virtual-in "place" "panel" "place")
           (virtual-out "out" "panel" "out")))
