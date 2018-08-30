#lang racket/gui

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)
(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))
(require/edge ${gui.widget})
(require/edge ${gui.snip})

(struct agt (place snip widget) #:prefab #:mutable)

(define (my-pb% state)
  (class pasteboard% (super-new); The base class is canvas%
    ; Define overriding method to handle mouse events
   (define/override (on-paint before?
                              dc
                              left top right bottom
                              dx dy
                              draw-caret)
     (for ([wdg (agt-place state)])
       ((widget-draw wdg) before? dc left top right bottom dx dy)))

    (define (after-select snip on?)
      (class-send snip send-event (cons 'select on?)))
    (augment after-select)

    (define (after-delete snip)
      (class-send snip send-event (cons 'is-deleted #t)))
    (augment after-delete)

    (define (after-move-to snip x y drag?)
      (class-send snip send-event (cons 'move-to (vector x y drag?))))
    (augment after-move-to)

    (define (can-interactive-resize? snip)
      #f)
    (augment can-interactive-resize?)

    (define (can-interactive-move? event)
      (if (eq? 'left-down (class-send event get-event-type))
          #t
          #f))
    (augment can-interactive-move?)
    ))

(define my-pb-s%
  (class editor-snip%
    (init input)

    (define port-input input)
    (super-new)

    (define/override (on-event dc x y editorx editory event)
      (send (port-input "in") (cons (class-send event get-event-type) event)))

    (define/public (send-event event)
      (send (port-input "in") event))))

(define-agent
  #:input '("in") ; in port
  #:input-array '("place" "snip")
  #:output '("out") ; out port
  #:output-array '("out")
   (define try-acc (try-recv (input "acc")))
   (define acc (or try-acc
                   (agt '() '() #f)))

   ; input "in"
   (define msg (if (not (agt-widget acc))
                   (recv (input "in"))
                   (try-recv (input "in"))))
   (match msg
     [#f (void)]
     [(cons 'init (vector x y))
      (define editor (new (my-pb% acc)))
      (define snp (new my-pb-s%
                       [input input]
                       [editor editor]
                       [with-border? #f]))
      (class-send snp set-flags '(handles-all-mouse-events))
      (set-agt-widget! acc snp)
      (send (output "out")
            (cons 'init (snip
                         0
                         x y
                         snp
                         )))]
     [(cons 'delete #t)
      (send (output "out") msg)]
     [else
      (send-action output output-array msg)])

   (for ([(place containee) (input-array "place")])
     (define msg (try-recv containee))
     (match msg
       [#f (void)]
       [(cons 'init wdg)
        ; set place
        (set! wdg (struct-copy widget wdg [id place]))
        ; Add it
        (add-ordered acc wdg)
        ]
       [(cons 'delete #t)
        (set-agt-place! acc
                        (filter (lambda (x)
                                  (not (eq?  place (widget-id x))))
                                (agt-place acc)))
        ]
       [else (send-action output output-array msg)]))

    ; Array input "snip" (snip on the pasteboard)
    (for ([(id-snip containee) (input-array "snip")])
      (define msg (try-recv containee))
      (match msg
        [#f (void)]
        [(cons 'init wdg)
         ; Insert the snip in agt
         (set! wdg (struct-copy snip wdg [id id-snip]))
         ; Save in the acc, and retrieve the "before" snip
         (define before (add-ordered-snip acc wdg))
         ; Insert in pasteboard
         (class-send (class-send (agt-widget acc) get-editor) insert
                     (snip-snip wdg)
                     before
                     (snip-x wdg) (snip-y wdg))
         ]
        [(cons 'delete #t)
         (define snp (findf (lambda (x) (eq? id-snip (snip-id x))) (agt-snip acc)))
         (define pb (class-send (agt-widget acc) get-editor))
         (class-send pb delete (snip-snip snp))
         (set-agt-snip! acc
                        (filter (lambda (x)
                                  (not (eq? id-snip (snip-id x))))
                                (agt-snip acc)))
         ]
        [else (send-action output output-array msg)]))

   (send (output "acc") acc))

(define (add-ordered acc widget)
  (define (add-ordered ls acc)
    (cond
      [(empty? ls) (reverse (cons widget acc))]
      [else
       (define comp (if (string? (widget-id (car ls)))
                        string>?
                        >))
        (if (comp (widget-id (car ls)) (widget-id widget))
            ; must add
            (append (reverse (cons widget acc)) ls)
            ; continue
            (add-ordered (cdr ls) (cons (car ls) acc)))]))
  (set-agt-place! acc (add-ordered (agt-place acc) '())))

(define (add-ordered-snip acc widget)
  (define before #f)
  (define (add-ordered ls acc)
    (cond
      [(empty? ls)
       (if (not (empty? acc))
           (set! before (snip-snip (car acc)))
           void)
       (reverse (cons widget acc))]
      [else
       (define comp (if (string? (snip-id (car ls)))
                        string>?
                        >))
       (if (comp (snip-id (car ls)) (snip-id widget))
           (begin
             ; must add
             (if (not (empty? acc))
                 (set! before (snip-snip (car acc)))
                 void)
             (append (reverse (cons widget acc)) ls))
           ; continue
           (add-ordered (cdr ls) (cons (car ls) acc)))]))
  (set-agt-snip! acc (add-ordered (agt-snip acc) '()))
  before)
