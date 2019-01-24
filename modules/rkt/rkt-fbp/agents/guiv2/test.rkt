#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/graph
         fractalide/modules/rkt/rkt-fbp/def)

(require/edge ${guiv2.list-counter})
(require/edge ${guiv2.counter})

(define imesg (cons 'list-counter (list-counter 1 (list (counter 0 0)))))

(define-graph
  (node "frame" ${guiv2.frame})

  (node "model" ${guiv2.model})
  (node "list" ${guiv2.list})

  (mesg "model" "in" imesg)
  (edge "model" "out" _ "list" "in" _)

  (edge "list" "out" _ "frame" "in" _)
  (edge "list" "out" 'list-counter "model" "in" _)

  (node "counter" ${guiv2.counter})
  (edge "list" "build" _ "counter" "in" _)
  (edge "counter" "out" _ "list" "build" _)
  (edge "counter" "out" 'counter "model" "in" _)

  (node "halt" ${halter})
  (mesg "halt" "in" #t)
  )
