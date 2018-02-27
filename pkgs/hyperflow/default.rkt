 #lang racket/base

(require racket/gui)

(require "gui/default.rkt")

(define hyperflow%
  (class object%
    (init parent)
    (gui parent)
    (super-new)))

(define frame (new frame% [label "Hyperflow"] [min-width 800] [min-height 500]))
(define hyperflow (new hyperflow% [parent frame]))
(send frame show #t)
