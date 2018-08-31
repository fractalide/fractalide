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

(struct snip-agt (place snip widget) #:prefab #:mutable)

(define (my-pb% state)
  (class pasteboard% (super-new); The base class is canvas%
    ; Define overriding method to handle mouse events
   (define/override (on-paint before?
                              dc
                              left top right bottom
                              dx dy
                              draw-caret)
     (if before?
         (void)
         (for ([wdg (snip-agt-place state)])
           ((widget-draw wdg) before? dc left top right bottom dx dy))))

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

(define (my-ed state input)
  (class editor-canvas% (super-new); The base class is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (define send? #f)
      (for/or ([wdg (reverse (snip-agt-place state))])
        (if ((widget-box wdg)
             (class-send this get-dc)
             (class-send event get-x)
             (class-send event get-y))
            (begin
              (set! send? #t)
              ((widget-event wdg) (cons (class-send event get-event-type) event))
              )
            ; False : send it from the pasteboard
            #f))
      (if send?
          void
          (send (input "in") (cons (class-send event get-event-type) event)))
      (super on-event event))
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (super on-char event))
    ; Call the superclass init, passing on all init args
    ))

(define (generate input)
  (lambda (frame)
    (let* ([state (snip-agt '() '() #f)]
           [canvas (new (my-ed state input)
                        [parent frame]
                        [editor (new (my-pb% state))]
                                          )])
      (set-snip-agt-widget! state canvas)
      (send (input "acc") state))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  (if managed
      (void)
      (match msg
        [(cons 'init #t)
         void]
        [else (send-action output output-array msg)])))

(define-agent
  #:input '("in") ; in port
  #:input-array '("place" "snip")
  #:output '("out") ; out port
  #:output-array '("out")
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
        (process-msg msg-in (snip-agt-widget acc) input output output-array)
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
         (class-send (snip-agt-widget acc) refresh)
         ]
        [(cons 'delete #t)
         (set-snip-agt-place! acc
                         (filter (lambda (x)
                                   (not (eq?  place (widget-id x))))
                                 (snip-agt-place acc)))
         (class-send (snip-agt-widget acc) refresh)
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
         (class-send (class-send (snip-agt-widget acc) get-editor) insert
                     (snip-snip wdg)
                     before
                     (snip-x wdg) (snip-y wdg))
         (class-send (snip-agt-widget acc) refresh)]
        [(cons 'delete #t)
         (define snp (findf (lambda (x) (eq? id-snip (snip-id x))) (snip-agt-snip acc)))
         (define pb (class-send (snip-agt-widget acc) get-editor))
         (class-send pb delete (snip-snip snp))
         (set-snip-agt-snip! acc
                        (filter (lambda (x)
                                  (not (eq? id-snip (snip-id x))))
                                (snip-agt-snip acc)))
         (class-send (snip-agt-widget acc) refresh)]
        [else (send-action output output-array msg)]
        ))

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
  (set-snip-agt-place! acc (add-ordered (snip-agt-place acc) '())))

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
  (set-snip-agt-snip! acc (add-ordered (snip-agt-snip acc) '()))
  before)
