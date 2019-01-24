#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require (prefix-in gui: racket/gui )
         racket/match)

(require/edge ${guiv2.list-counter})
(require/edge ${guiv2.counter})

(define-agent
  #:input '("in" "build") ; in port
  #:output '("out" "buid") ; out port
  #:output-array '("out")
  (define msg (recv (input "in")))

  (match msg
    [(vector 'delete c ls)
     (define new (struct-copy list-counter ls
                              [counters (remove c (list-counter-counters ls))]))
     (send-action output output-array `(list-counter . ,new))]
    [(cons 'add ls)
     (define n-id (+ (list-counter-next-id ls) 1))
     (define new (struct-copy list-counter ls
                  [next-id n-id]
                  [counters (cons (counter n-id 0) (list-counter-counters ls))]))
     (send-action output output-array `(list-counter . ,new))]
    [(cons 'list-counter ls)
     (define counters (map (lambda(c)
                             (send (output "build") `(counter . ,c))
                             (add-del c ls (cdr (recv (input "build"))) (input "in")))
                           (list-counter-counters ls)))
     (send (output "out") (cons 'init (disp ls (input "in") counters)))]
    [else (display "msg: ") (displayln msg)]))

(define (disp ls inport counters)
  (lambda(frame)
    (define vp (gui:new gui:vertical-panel%
                        [parent frame]
                        [stretchable-height #f]))
    (gui:new gui:button% [parent vp]
         [label "add"]
         [callback (lambda (button event)
                     (send inport (cons 'add ls)))])
    (for [(c counters)]
      (c vp))
    ))

(define (add-del c ls disp inport)
  (lambda(frame)
    (define hp (gui:new gui:horizontal-panel%
                        [parent frame]
                        [stretchable-width #f]))
    (disp hp)
    (gui:new gui:button% [parent hp]
             [label "x"]
             [callback (lambda (button event)
                         (send inport (vector 'delete c ls)))])))
