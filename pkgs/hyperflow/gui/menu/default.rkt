#lang racket/base

(require racket/gui)
(provide menu)

(define (menu parent)
  (define menu-panel
    (new horizontal-panel%
         [parent parent]
         [min-height 1]
         [alignment '(right top)]))
  (define mb (new menu-bar% [parent parent]))
  (define m-file (new menu% [label "File"] [parent mb]))
  (define m-edit (new menu% [label "Edit"] [parent mb]))
  (define m-hf (new menu% [label "Hyperflow"] [parent mb]))
  (define (develop-button-callback develop-button event)
    (printf "event ~v" event))
  (define (graph-button-callback graph-button event)
    (printf "event ~v" event))
  (define (run-button-callback run-button event)
    (printf "event ~v" event))
  (define develop-button
    (new button%
         [label "Develop"]
         [vert-margin 3]
         [horiz-margin 0]
         [parent menu-panel]
         [callback develop-button-callback]))
  (define graph-button
    (new button%
         [label "Graph"]
         [vert-margin 3]
         [horiz-margin 0]
         [parent menu-panel]
         [callback graph-button-callback]))
  (define run-button
    (new button%
         [label "Run"]
         [vert-margin 3]
         [horiz-margin 0]
         [parent menu-panel]
         [callback run-button-callback]))
  parent)
