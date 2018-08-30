#lang racket

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${hyperflow.graph.line})

(define-agent
  #:input '("in") ; in array port
  #:input-array '()
  #:output '("out" "name") ; out port
  #:output-array '("out")
    (define msg (recv (input "in")))
    (define acc (try-recv (input "acc")))
    (match msg
      [(cons 'init (vector name))
       ;(set! acc (line id x y x-end y-end))
       (send (output "name") (cons 'init (list (cons 'label "Name:")
                                               (cons 'init-value name))))]
      [(cons 'text-field name)
       (send (output "out") (cons 'set-name name))]
      [else (send (output "out") msg)])
    (send (output "acc") acc))
