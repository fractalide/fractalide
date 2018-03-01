 #lang racket/base

(require racket/gui)

(provide run)

(require "gui/default.rkt")

(define hyperflow%
  (class object%
    (init parent)
    (gui parent)
    (super-new)))

(define (run)
  (define main (new frame% [label "Hyperflow"] [min-width 800] [min-height 500]))
  (define hyperflow (new hyperflow% [parent main]))
  (send main show #t))
