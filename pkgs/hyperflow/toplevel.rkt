#lang racket/base

(require racket/gui
         "utilities.rkt"
         "fractal-node-edge-dialog.rkt")

(provide toplevel-window%)

(define (make-file-menu menu-bar toplevel)
  (define file-menu (new menu% [parent menu-bar] [label "&File"]))

  (new menu-item%
       [parent file-menu] [label "E&xit"]
       [shortcut #\Q]
       [callback (λ (m e) (send toplevel on-exit))])

  file-menu)

(define (make-edit-menu menu-bar toplevel)
  (define edit-menu (new menu% [parent menu-bar] [label "&Edit"]))

  (define use-menu 
    (new checkable-menu-item%
         [label "Advanced"]
         [parent edit-menu]
         [checked #t]
         [callback (λ (i e) 
                     (display "Advanced")
                     (display "End User"))]))

  edit-menu)

(define (make-hyperflow-menu menu-bar toplevel)
  (define hyperflow-menu (new menu% [parent menu-bar] [label "&Hyperflow"]))
  
  (define new-fractal-menu 
    (new menu-item% 
         [label "New Fractal"]
         [parent hyperflow-menu]
         [callback (λ (i e) (new-fractal-dialog))]))
  (define new-node-menu 
    (new menu-item% 
         [label "New Node"]
         [parent hyperflow-menu]
  [callback (λ (i e) (new-node-dialog))]))
  (define new-edge-menu 
    (new menu-item% 
         [label "New Edge"]
         [parent hyperflow-menu]
  [callback (λ (i e) (new-edge-dialog))]))
  (new separator-menu-item% [parent hyperflow-menu ])
  (define dev-mode-menu 
    (new menu-item% 
         [label "Develop Mode"]
         [parent hyperflow-menu]
         [callback (λ (i e) (send hyperflow-menu set-size 4))]
         [shortcut #\d]))
  (define graph-mode-menu 
    (new menu-item% 
         [label "Graph Mode"]
         [parent hyperflow-menu]
         [callback (λ (i e) (new-node-dialog))]
         [shortcut #\g]))
  (define run-edge-menu 
    (new menu-item% 
         [label "Run Mode"]
         [parent hyperflow-menu]
         [callback (λ (i e) (new-edge-dialog))]
         [shortcut #\r]))
  hyperflow-menu)

(define toplevel-window%
  (class object%
    (super-new)
    (define tl-frame
      (let ((dims (get-pref 'hyperflow:frame-dimensions (λ () (cons 1200 750)))))
        (new
         (class frame% (init) (super-new)
           (define/augment (on-close) (send this show #f) (on-toplevel-close #t))
           (define/augment (can-close?) (can-close-toplevel?))
           (define/override (can-exit?) (can-close-toplevel?)))
         [width (car dims)] [height (cdr dims)]
         [style '(fullscreen-button)]
         [label (format "Hyperflow")])))
    
    (define the-selected-section #f)
    
    (let ((mb (new menu-bar% [parent tl-frame])))
      (make-file-menu mb this)
      (make-edit-menu mb this)
      (make-hyperflow-menu mb this))
    
    (define (can-close-toplevel?)
      (check-unsaved-edits))
    
    (define (check-unsaved-edits) #t)
    
    (define (on-toplevel-close (exit-application? #f))
      (unless (or (send tl-frame is-maximized?) (send tl-frame is-fullscreened?))
        (let-values (([w h] (send tl-frame get-size)))
          (put-pref 'hyperflow:frame-dimensions (cons w h))))
      (put-pref 'hyperflow:frame-maximized (send tl-frame is-maximized?))
      (when exit-application?
        (exit 0)))

    (define/public (on-exit)
      (when (can-close-toplevel?)
        (send tl-frame show #f)
        (on-toplevel-close #t)))
    
    (define/public (run)
      (send tl-frame show #t))))

