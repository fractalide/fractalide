#lang racket/base

(require racket/class
         racket/gui/base
         "fractal-management/default.rkt")

(provide new-fractal-dialog new-node-dialog new-edge-dialog)
; handlers
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
  (define (create-fractal fractal-name-txt fractal-lang-txt)
    (define name (send fractal-name-txt get-value))
    (define lang (send fractal-lang-txt get-value))
    (unless (not (or name lang))
      (build-fractal name lang)))
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


