#lang racket

(provide g)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define g
  (make-graph
    (node "jsend" ${paging-jsend-get})
    (node "mock" ${paging-jsend-get.test.mock})
    (edge "jsend" "send-request" "mock" "in")
    (edge "mock" "out" "jsend" "recv-response")
    (edge "jsend" "send-response" "mock" "jsend")
    (edge-out "mock" "state" "state"))
