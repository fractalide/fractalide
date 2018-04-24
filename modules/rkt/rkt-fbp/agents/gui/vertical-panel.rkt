#lang racket/base

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g (make-graph (list
                       (add-agent "panel" "gui/horizontal-panel")
                       (iip "panel" "in" (vector "set-orientation" #f))
                       (virtual-in "in" "panel" "in")
                       (virtual-in "place" "panel" "place")
                       (virtual-out "out" "panel" "out"))))
