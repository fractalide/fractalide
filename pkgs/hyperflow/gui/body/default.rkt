#lang racket/base

(require racket/gui)
(provide body)

(define (body parent)
  (define body-panel
    (new horizontal-panel%
         [parent parent]
         [min-height 500]
         [alignment '(left bottom)]
         ))
  (define titleoutput
    (new canvas% [parent body-panel]
         [paint-callback
          (lambda (canvas dc)
            (send dc set-scale 1 1)
            (send dc set-text-foreground "black")
            (send dc draw-text "Hyperflow" 0 0))]))
  parent)
