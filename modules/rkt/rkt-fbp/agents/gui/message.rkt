#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match)
(require (prefix-in class: racket/class))

(define base-default
  (hash 'label #f
        'auto-resize #t
        'style '()
        'font normal-control-font
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
    (let* ([cb (class:new (with-event message% input) [parent frame]
                          [auto-resize (hash-ref default 'auto-resize)]
                          [label (hash-ref default 'label)]
                          [style (hash-ref default 'style)]
                          [font (hash-ref default 'font)]
                          [enabled (hash-ref default 'enabled)]
                          [vert-margin (hash-ref default 'vert-margin)]
                          [horiz-margin (hash-ref default 'horiz-margin)]
                          [min-width (hash-ref default 'min-width)]
                          [min-height (hash-ref default 'min-height)]
                          [stretchable-width (hash-ref default 'stretchable-width)]
                          [stretchable-height (hash-ref default 'stretchable-height)])])
      (send (input "acc") cb))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  (set! managed (area-manage widget msg output output-array))
  (set! managed (subarea-manage widget msg output output-array))
  (set! managed (window-manage widget msg output output-array))
  (if managed
      (void)
      (match msg
        [(cons 'get-auto-resize act)
         (send-action output output-array (cons act (class:send widget get-auto-resize)))]
        [(cons 'set-auto-resize b)
         (class:send widget set-auto-resize b)]
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
