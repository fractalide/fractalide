#lang racket

(require rackunit)
(require rackunit/text-ui)

(require paging-jsend-get)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/port)
(require fractalide/modules/rkt/rkt-fbp/scheduler)

(require fractalide/modules/rkt/rkt-fbp/scheduler) ;;debug

(define suite
  (test-suite "paging-jsend-get"
    (test-case
      "Trivial HTTP request returning 1 item only"
      (define sched (make-scheduler #f))
      (define state-port (make-port 30 #f #f #f))
      (for ([msg (list (msg-add-agent "jsend" 'paging-jsend-get)
                       (msg-add-agent "mock" 'paging-jsend-get/test/mock)
                       (msg-connect "jsend" "send-request" "mock" "in")
                       (msg-connect "mock" "out" "jsend" "recv-response")
                       (msg-connect "jsend" "send-response" "mock" "jsend")
                       (msg-raw-connect "mock" "state" state-port))])
        (sched msg))

      (define url "http://example.com/api/hello")

      (sched (msg-mesg "jsend" "recv-request" (http-get-request url #f)))
      (define state (port-recv state-port))
      (sched (msg-stop))

      (check-true (hash-has-key? state 'request) "got http request")
      (match-define (http-get-request got-url _) (hash-ref state 'request))
      (check-equal? got-url url "got correct url")
      (check-true (hash-has-key? state 'jsend-response) "got jsend response")
      (match-define (list response1 response2) (hash-ref state 'jsend-response))
      (match-define (json-data response1-data) response1)
      (check-equal? response1-data "hello world" "got the unwrapped message")
      (check-equal? response2 eof "got eof after message"))))

(module+ main
  (if (> (run-tests suite) 0)
      (exit 1)
      (exit 0)))
