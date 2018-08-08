#lang racket/gui

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)
(require racket/gui/base
         racket/match)
(require (rename-in racket/class [send class-send]))
(require/edge ${gui.snip})

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
  #:output-array '("out")
  (fun
   (define msg (recv (input "in")))
   (match msg
     [(cons 'init (vector x y path))
      (define snp (make-object image-snip% path))
      (send (output "out")
            (cons 'init (snip
                         0
                         x y
                         snp
                         (lambda (event)
                           (send (input "in") event)))))]
     [(cons 'delete #t)
      (send (output "out") msg)]
     [else
      (send-action output output-array (cons (class-send msg get-event-type) msg))])))
