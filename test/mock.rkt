#lang racket

(require json)

(require fractalide/modules/rkt/rkt-fbp/agent)

(require paging-jsend-get)

(define-agent
  #:input '("in" "jsend")
  #:output '("out" "state")
  (fun
   (define state (make-hash))
   (define request (recv (input "in")))
   (match-define (http-get-request url _) request)
   (hash-set! state 'request request)
   (send
    (output "out")
    (http-response 200 '()
                   (jsexpr->bytes
                    #hash((status . "success")
                          (data . ("hello world"))
                          (meta . #hash((pagination . #hash((page . 1)
                                                            (perPage . 1)
                                                            (totalPages . 1)
                                                            (totalEntries . 1)))))))))
   (define jsend-response (list (recv (input "jsend")) (recv (input "jsend"))))
   (hash-set! state 'jsend-response jsend-response)
   (send (output "state") state)))
