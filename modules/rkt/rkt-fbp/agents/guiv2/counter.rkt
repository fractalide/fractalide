#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require (prefix-in gui: racket/gui))

(require/edge ${guiv2.counter})

(define-agent
  #:input '("in") ; in port
  #:output '("out") ; out port
  #:output-array '("out")
  (define msg (recv (input "in")))

  (match msg
    [(cons 'sub ctr)
     (send-action output output-array (cons 'counter
                                            (struct-copy counter ctr [val (- (counter-val ctr) 1)])))]
    [(cons 'add ctr)
     (send-action output output-array (cons 'counter
                                (struct-copy counter ctr [val (+ (counter-val ctr) 1)])))]
    [(cons 'counter counter)
     (send (output "out") (cons 'init (transform counter (input "in"))))]
    [else (send-action output output-array msg)]))

(define (transform counter inport)
  (lambda(frame)
    (define hp (gui:new gui:horizontal-panel% [parent frame]))
    (gui:new gui:button% [parent hp]
         [label "-"]
         [callback (lambda (button event)
                     (send inport (cons 'sub counter)))])
    (gui:new gui:message% [parent hp]
                     [label (number->string (counter-val counter))])
    (gui:new gui:button% [parent hp]
         [label "+"]
         [callback (lambda (button event)
                     (send inport (cons 'add counter)))])))
