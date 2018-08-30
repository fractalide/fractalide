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
   (define msg (recv (input "in")))
   (match msg
     [(cons 'init (vector x y end-x end-y))
      (send (output "out")
            (cons 'init (widget
                         0
                         (lambda (before? dc left top right bottom dx dy)
                           (if before?
                               (void)
                               (class-send dc draw-line
                                           (+ x dx) (+ y dy)
                                           (+ end-x dx) (+ end-y dy))))
                         ; TODO: Be more precise for click on the line...
                         (lambda (dc a b)
                           (define min-x (min x end-x))
                           (define max-x (max x end-x))
                           (define min-y (min y end-y))
                           (define max-y (max y end-y))
                           (and (> a min-x)
                                (< a max-x)
                                (> b min-y)
                                (< b max-y)))
                         (lambda (event)
                           (send (input "in") event)))))]
     [(cons 'delete #t)
      (send (output "out") msg)]
     [else
      (send-action output output-array msg)]))
