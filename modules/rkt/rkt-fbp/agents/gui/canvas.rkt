#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match
         racket/list)
(require (rename-in racket/class [send class-send]))

(require/edge ${gui.widget})

(struct state (widget) #:prefab #:mutable)

(define (my-canvas state)
  (class canvas% (super-new); The base class is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (displayln "Canvas mouse")
      (for/or ([wdg (reverse (state-widget state))])
        (if ((widget-box wdg)
             (class-send this get-dc)
             (class-send event get-x)
             (class-send event get-y))
            ((widget-event wdg) event)
            #f)))
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (displayln "Canvas keyboard"))
    ; Call the superclass init, passing on all init args
    ))

(define (generate input)
  (lambda (frame)
    (let* ([state (state '())]
           [canvas (new (my-canvas state) [parent frame]
                        [paint-callback (lambda (canvas dc)
                                          (for ([wdg (state-widget state)])
                                            ((widget-draw wdg) dc)
                                            )
                                          )])])
      (send (input "acc") (cons state canvas)))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  (if managed
      (void)
      (match msg
             [else (send-action output output-array msg)])))

(define-agent
  #:input '("in") ; in port
  #:input-array '("place")
  #:output '("out") ; out port
  #:output-array '("out")
    (define acc (try-recv (input "acc")))
    (define msg-in (try-recv (input "in")))
    ; Init the first time
    (define canvas (if acc
                   acc
                   (begin
                     (send (output "out") (cons 'init (generate input)))
                     (recv (input "acc")))))

    (if msg-in
        ; TRUE : A message in the input port
        (process-msg msg-in (cdr canvas) input output output-array)
        ; FALSE : At least a message in the input array port
        (for ([(place containee) (input-array "place")])
             (define msg (try-recv containee))
             (if msg
                 (match msg
                        [(cons 'init wdg)
                         ; set place
                         (set! wdg (struct-copy widget wdg [id place]))
                         ; Add it
                         (add-ordered (car canvas) wdg)
                         ; Redraw
                         (class-send (cdr canvas) refresh)
                         ]
                        [(cons 'delete #t)
                         (set-state-widget! (car canvas)
                                            (filter (lambda (x)
                                                      (not (=  place (widget-id x))))
                                                    (state-widget (car canvas))))
                         (class-send (cdr canvas) refresh)
                         ]
                        [else (send-action output output-array msg)])
                 void)))

    (send (output "acc") canvas))

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
  (set-state-widget! acc (add-ordered (state-widget acc) '())))
