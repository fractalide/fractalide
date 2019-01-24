#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${guiv2.list-counter})
(require/edge ${guiv2.counter})

(define-agent
  #:input '("in") ; in array port
  #:output '("out") ; out port
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'list-counter ls)
       (set! acc ls)
       (send (output "out") msg)]
      [(cons 'counter counter)
       (define new (map (lambda(c)
                          (if (= (counter-id c) (counter-id counter))
                              counter
                              c))
                        (list-counter-counters acc)))
       (set! acc (struct-copy list-counter acc [counters new]))
       (send (output "out") `(list-counter . ,acc))]
      [else (void)])
    (send (output "acc") acc))
