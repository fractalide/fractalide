#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match
         racket/list)
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
    ))

(define (my-ed state)
  (class editor-canvas% (super-new); The base class is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (displayln "Canvas mouse")
      (for/or ([wdg (reverse (agt-place state))])
        (if ((widget-box wdg)
             (class-send this get-dc)
             (class-send event get-x)
             (class-send event get-y))
            ((widget-event wdg) event)
            #f))
      (super on-event event))
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (displayln "Canvas keyboard")
      (super on-char event))
    ; Call the superclass init, passing on all init args
    ))

(define (generate input)
  (lambda (frame)
    (let* ([state (agt '() '() #f)]
           [canvas (new (my-ed state)
                        [parent frame]
                        [editor (new (my-pb% state))]
                                          )])
      (set-agt-widget! state canvas)
      (send (input "acc") state))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  (if managed
      (void)
      (match msg
             [else (send-action output output-array msg)])))

(define-agent
  #:input '("in") ; in port
  #:input-array '("place" "snip")
  #:output '("out") ; out port
  #:output-array '("out")
  (fun
    (define try-acc (try-recv (input "acc")))

    ; Init the first time
    (define acc (if try-acc
                   try-acc
                   (begin
                     (send (output "out") (cons 'init (generate input)))
                     (recv (input "acc")))))

    (define msg-in (try-recv (input "in")))
    ; Input "in"
    (if msg-in
        ; TRUE : A message in the input port
        (process-msg msg-in (agt-widget acc) input output output-array)
        void)
    ; Array input "place" (widget on the canvas)
    (for ([(place containee) (input-array "place")])
      (define msg (try-recv containee))
      (match msg
        [#f (void)]
        [(cons 'init wdg)
         ; set place
         (set! wdg (struct-copy widget wdg [id place]))
         ; Add it
         (add-ordered acc wdg)
         ; Redraw
         (class-send (agt-widget acc) refresh)
         ]
        [(cons 'delete #t)
         (set-agt-place! acc
                         (filter (lambda (x)
                                   (not (=  place (widget-id x))))
                                 (agt-place acc)))
         (class-send (agt-widget acc) refresh)
         ]
        [else (send-action output output-array msg)])
      )
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
         (class-send (agt-widget acc) refresh)]
        [(cons 'delete #t)
         (define snp (findf (lambda (x) (= id-snip (snip-id x))) (agt-snip acc)))
         (define pb (class-send (agt-widget acc) get-editor))
         (class-send pb delete (snip-snip snp))
         (set-agt-snip! acc
                        (filter (lambda (x)
                                  (not (= id-snip (snip-id x))))
                                (agt-snip acc)))
         (class-send (agt-widget acc) refresh)]
        [else (send-action output output-array msg)]
        ))

    (send (output "acc") acc)))

(define (add-ordered acc widget)
  (define (add-ordered ls acc)
    (cond
      [(empty? ls) (reverse (cons widget acc))]
      [else
        (if (> (widget-id (car ls)) (widget-id widget))
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
       (if (> (snip-id (car ls)) (snip-id widget))
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
