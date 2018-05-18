#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match)
(require (prefix-in class: racket/class))

(define base-default
  (hash 'label #f
        'min-value #f
        'max-value #f
        'style '(horizontal)
        'font normal-control-font
        'init-value #f
        'enabled #t
        'vert-margin 2
        'horiz-margin 2
        'min-width #f
        'min-height #f
        'stretchable-width #f
        'stretchable-height #f))

(define (generate input data)
  (lambda (frame)
    (define default (for/fold ([acc base-default])
                              ([d data])
                      (hash-set acc (car d) (cdr d))))
    (let* ([cb (class:new (with-event slider% input) [parent frame]
                          [label (hash-ref default 'label)]
                          [min-value (hash-ref default 'min-value)]
                          [max-value (hash-ref default 'max-value)]
                          [init-value (or (hash-ref default 'init-value) (hash-ref default 'min-value))]
                          [callback (lambda (widget event)
                                      (send (input "in") (cons 'slider (class:send widget get-value))))]
                          [style (hash-ref default 'style)]
                          [font (hash-ref default 'font)]
                          [enabled (hash-ref default 'enabled)]
                          [vert-margin (hash-ref default 'vert-margin)]
                          [horiz-margin (hash-ref default 'horiz-margin)]
                          [min-width (hash-ref default 'min-width)]
                          [min-height (hash-ref default 'min-height)]
                          [stretchable-width (or (hash-ref default 'stretchable-width)
                                                 (memq 'horizontal (hash-ref default 'style))
                                                 )]
                          [stretchable-height (or (hash-ref default 'stretchable-height)
                                                  (memq 'vertical (hash-ref default 'style)))])])
      (send (input "acc") cb))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  (set! managed (area-manage widget msg output output-array))
  (set! managed (subarea-manage widget msg output output-array))
  (set! managed (window-manage widget msg output output-array))
  (if managed
      (void)
      (match msg
        [(cons 'get-value act)
         (send-action output output-array (cons act (class:send widget get-value)))]
        [(cons 'set-value v)
         (class:send widget set-value v)]
        [else (send-action output output-array msg)])))

(define agt
  (define-agent
    #:input '("in") ; in port
    #:output '("out") ; out port
    #:output-array '("out")
    #:proc
    (lambda (input output input-array output-array)
      (define acc (try-recv (input "acc")))
      (define msg (recv (input "in")))
      (set! acc (manage acc msg input output output-array generate process-msg))
      (send (output "acc") acc))))
