 #lang racket/gui

(define hyperflow%
  (class object%
    (init parent)
    (super-new)
    (define menu-panel
      (new horizontal-panel%
           [parent parent]
           [min-height 1]
           [alignment '(right top)]))
    (define mb (new menu-bar% [parent parent]))
    (define m-file (new menu% [label "File"] [parent mb]))
    (define m-edit (new menu% [label "Edit"] [parent mb]))
    (define m-hf (new menu% [label "Hyperflow"] [parent mb]))
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
    (define (develop-button-callback develop-button event)
      (printf "event ~v" event))
    (define (graph-button-callback graph-button event)
      (printf "event ~v" event))
    (define (run-button-callback run-button event)
      (printf "event ~v" event))
    (define develop-button
      (new button%
           [label "Develop"]
           [vert-margin 5]
           [horiz-margin 2]
           [parent menu-panel]
           [callback develop-button-callback]))
    (define graph-button
      (new button%
           [label "Graph"]
           [vert-margin 5]
           [horiz-margin 2]
           [parent menu-panel]
           [callback graph-button-callback]))
    (define run-button
      (new button%
           [label "Run"]
           [vert-margin 5]
           [horiz-margin 2]
           [parent menu-panel]
           [callback run-button-callback]))))

(define f (new frame% [label "Hyperflow"] [min-width 800] [min-height 500]))

(define tib (new hyperflow%
                 [parent f]))

(send f show #t)