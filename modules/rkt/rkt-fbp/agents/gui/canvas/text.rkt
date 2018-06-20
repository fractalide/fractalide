#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)
(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))
(require/edge ${gui.widget})

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
  #:output-array '("out")
  (fun
   (define msg (recv (input "in")))
   (match msg
     [(cons 'init (vector text x y))
      (send (output "out")
            (cons 'init (widget
                         0
                         (lambda (dc)
                           (class-send dc draw-text text x y))
                         (lambda (dc a b)
                           (define-values (width height _ __) (class-send dc get-text-extent text))
                           (and (> a x)
                                (< a (+ x width))
                                (> b y)
                                (< b (+ y height))))
                         (lambda (event)
                           (send (input "in") event)))))]
     [(cons 'delete #t)
      (send (output "out") msg)]
     [else (display "msg in text: ") (displayln msg)])
   ))
