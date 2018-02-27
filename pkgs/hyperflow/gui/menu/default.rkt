#lang racket/base

(require racket/gui)
(require "../../fractal-management/default.rkt")

(provide menu)

(define (menu parent)
  (define menu-bar 
    (new menu-bar% 
         [parent parent]))
  (define file-menu 
    (new menu% 
         [label "File"]
         [parent menu-bar]))
  (define quit-menu 
    (new menu-item% 
         [label "Exit"]
         [parent file-menu]
         [callback (λ (i e) (send parent show #f))]
         [shortcut #\q]))
  (define edit-menu
    (new menu%
         [label "Edit"]
         [parent menu-bar]))
  (define use-menu 
    (new checkable-menu-item%
         [label "Advanced"]
         [parent edit-menu]
         [checked #t]
         [callback (λ (i e) 
                     (display "Advanced")
                     (display "End User"))]))
  (define hyperflow-menu
    (new menu%
         [label "Hyperflow"]
         [parent menu-bar]))
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
  (define help-menu
    (new menu%
         [label "Help"]
         [parent menu-bar]))
  (define about-menu
    (new menu-item%
         [label "About"]
         [parent help-menu]
         [callback (λ (i e) (void))]))
  (define menu-panel
    (new horizontal-panel%
         [parent parent]
         [min-height 1]
         [alignment '(right top)]))
  
;; dialogs
  (define (new-fractal-dialog)
    (define nf-dialog
      (new dialog%
           [label "New Fractal"]
           [min-width 200]
           [min-height 50]))
    (define fractal-name-txt
      (new text-field%
           [parent nf-dialog]
           [label "Fractal Name"]))
    (define fractal-lang-txt
      (new text-field%
           [parent nf-dialog]
           [label "Language"]))
    (define panel
      (new horizontal-panel%
           [parent nf-dialog]
           [alignment '(center center)]))
    (new button%
         [parent panel]
         [label "Cancel"]
         [callback (λ (i e) (send nf-dialog show #f))])
    (new button%
         [parent panel]
         [label "Ok"]
         [callback
          (λ (i e)
            (create-fractal fractal-name-txt fractal-lang-txt)
            (send nf-dialog show #f))])
    (when (system-position-ok-before-cancel?)
      (send panel change-children reverse))
    (send nf-dialog show #t))

  (define (new-node-dialog)
    (define nn-dialog
      (new dialog%
           [label "New Node"]
           [min-width 200]
           [min-height 50]))
    (define fractal-name-txt
      (new text-field%
           [parent nn-dialog]
           [label "Fractal Name"]))
    (define language-txt
      (new text-field%
           [parent nn-dialog]
           [label "Language"]))
    (define node-name-txt
      (new text-field%
           [parent nn-dialog]
           [label "Node Name"]))
    (define panel
      (new horizontal-panel%
           [parent nn-dialog]
           [alignment '(center center)]))
    (new button%
         [parent panel]
         [label "Cancel"]
         [callback (λ (i e) (send nn-dialog show #f))])
    (new button%
         [parent panel]
         [label "Ok"]
         [callback
          (λ (i e)
            (create-node fractal-name-txt language-txt node-name-txt)
            (send nn-dialog show #f))])
    (when (system-position-ok-before-cancel?)
      (send panel change-children reverse))
    (send nn-dialog show #t))

  (define (new-edge-dialog)
    (define ne-dialog
      (new dialog%
           [label "New Node"]
           [min-width 200]
           [min-height 50]))
    (define fractal-name-txt
      (new text-field%
           [parent ne-dialog]
           [label "Fractal Name"]))
    (define language-txt
      (new text-field%
           [parent ne-dialog]
           [label "Language"]))
    (define edge-name-txt
      (new text-field%
           [parent ne-dialog]
           [label "Edge Name"]))
    (define panel
      (new horizontal-panel%
           [parent ne-dialog]
           [alignment '(center center)]))
    (new button%
         [parent panel]
         [label "Cancel"]
         [callback (λ (i e) (send ne-dialog show #f))])
    (new button%
         [parent panel]
         [label "Ok"]
         [callback
          (λ (i e)
            (create-edge fractal-name-txt language-txt edge-name-txt)
            (send ne-dialog show #f))])
    (when (system-position-ok-before-cancel?)
      (send panel change-children reverse))
    (send ne-dialog show #t))

;; handlers
  (define (create-fractal fractal-name-txt fractal-lang-txt)
    (define name (send fractal-name-txt get-value))
    (define lang (send fractal-lang-txt get-value))
    (unless (not (or name lang))
      (build-fractal name lang)))
  
  (define (create-node fractal-name-txt language-txt node-name-txt)
    (define fname (send fractal-name-txt get-value))
    (define lang (send language-txt get-value))
    (define nname (send node-name-txt get-value))
    (unless (not (or fname lang nname))
      (build-node fname lang nname)))

  (define (create-edge fractal-name-txt language-txt edge-name-txt)
    (define fname (send fractal-name-txt get-value))
    (define lang (send language-txt get-value))
    (define ename (send edge-name-txt get-value))
    (unless (not (or fname lang ename))
      (build-edge fname lang ename)))
  
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
