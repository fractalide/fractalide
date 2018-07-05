#lang racket

(require rackunit)
(require rackunit/text-ui)

(require racket/async-channel) ;;debug

(require paging-jsend-get)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/edges/fvm/dynamic-add)
(require fractalide/modules/rkt/rkt-fbp/graph)
(require fractalide/modules/rkt/rkt-fbp/port)
(require fvm/wrapper)

(require fractalide/modules/rkt/rkt-fbp/scheduler) ;;debug

(define suite
  (test-suite "paging-jsend-get"
    (call-with-new-fvm-and-scheduler (lambda (fvm scheduler)
      (define state-port (make-port 30 #f #f #f))
      (define path (fbp-agents-string->symbol "paging-jsend-get/test/graph"))
      (define a-graph (make-graph (node "main" path)))
      (fvm (msg-mesg "fvm" "in" (cons 'dynamic-add (dynamic-add a-graph state-port))))

      (define url "http://example.com/api/hello")

      (scheduler (msg-mesg "jsend" "get-request" (http-get-request url #f)))
      (define state (port-recv state-port))

      (check-true (hash-has-key? state 'request) "got http request")
      (match-define (http-get-request got-url _) (hash-ref state 'request))
      (check-equal? got-url url "got correct url")
      (check-true (hash-has-key? state 'jsend-response) "got jsend response")
      (match-define (list response1 response2) (hash-ref state 'jsend-response))
      (check-equal? response1 "hello world" "got the unwrapped message")
      (check-equal? response2 eof "got eof after message")))))

(module+ main
  (if (> (run-tests suite) 0)
      (exit 1)
      (exit 0)))
