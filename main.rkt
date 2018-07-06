#lang racket

(require json)
(require net/url)

(require fractalide/modules/rkt/rkt-fbp/agent)

; (module typed typed/racket
(module typed racket
; JSExpr will exist when we depend on typed-racket-more
  (provide (all-defined-out))
  (struct http-get-request (
;    [url : String]
;    [accept : (U String #f)])
   url accept)
    #:prefab)
  (struct json-data (
;    [data : JSExpr])
;    [data : Any])
    data)
    #:prefab)
  (struct json-fail (
;    [data : JSExpr])
;    [data : Any])
    data)
    #:prefab)
  (struct json-error (
;    [data : JSExpr]
;    [data : Any]
;    [message : String]
;    [code : Integer])
    data message code)
    #:prefab)
  (struct http-response (
;    [status : Integer]
;    [headers : (Immutable-HashTable Symbol String)]
;    [data : Bytes])
    status headers data)
    #:prefab)
  (struct http-error (
;    [message : String])
    message)
    #:prefab))

(require 'typed)

(provide
  (struct-out http-get-request)
  (struct-out http-response)
  (struct-out http-error)
  (struct-out json-data)
  (struct-out json-fail)
  (struct-out json-error)
  agt)

(define (url-with-page u page)
  (define query (url-query u))
  (define new-query (hash->list (hash-set (make-immutable-hash query) 'page (number->string page))))
  (struct-copy url u (query new-query)))

(define agt
  (define-agent
    #:input '("in" "http")
    #:output '("out" "http")
    #:proc
    (lambda (input output input-array output-array)

(define (do-get-request url accept)
  (send (output "http")
        (http-get-request (url->string url) (if accept accept #"application/json")))
  (define response (recv (input "http")))
  (match response
    [(http-error _) (send (output "out") response)]
    [(http-response status headers data)
     (define jsexpr (with-input-from-bytes data read-json))
     (match jsexpr
       [(hash-table ('status "fail") ('data data))
        (send (output "out") (json-fail data))]
       [(hash-table ('status "error"))
        (send (output "out")
              (json-error 
                (hash-ref jsexpr 'diagnostic (hash-ref jsexpr 'data #hash()))
                (hash-ref jsexpr 'message "")
                (hash-ref jsexpr 'code status)))]
       [(hash-table
          ('status "success")
          ('data (list _ ...))
          ('meta (hash-table ('pagination
            (hash-table ('totalPages total-pages) ('page page) ('perPage per-page) ('totalEntries total-entries))))))
        (for ([elem (hash-ref jsexpr 'data)])
          (send (output "out")
                (json-data elem)))
        (if (> total-pages page)
            (do-get-request (url-with-page url (+ 1 (string->number page))) accept)
            (send (output "out") eof))]
       [(hash-table ('status "success") ('data data))
        (send (output "out" (json-data data)))
        (send (output "out" eof))])]))

      (define request (recv (input "in")))
      (match-define (http-get-request url accept) request) 
      (do-get-request (string->url url) accept))))

(module+ test
  (require rackunit)
  (require fractalide/modules/rkt/rkt-fbp/def)
  (require fractalide/modules/rkt/rkt-fbp/port)
  (require fractalide/modules/rkt/rkt-fbp/scheduler)

    (test-case
      "Trivial HTTP request returning 1 item only"
      (define sched (make-scheduler #f))
      (define state-port (make-port 30 #f #f #f))
      (for ([msg (list (msg-add-agent "jsend" 'paging-jsend-get)
                       (msg-add-agent "mock" 'paging-jsend-get/test/mock)
                       (msg-connect "jsend" "http" "mock" "in")
                       (msg-connect "mock" "out" "jsend" "http")
                       (msg-connect "jsend" "out" "mock" "jsend")
                       (msg-raw-connect "mock" "state" state-port))])
        (sched msg))

      (define url "http://example.com/api/hello")

      (sched (msg-mesg "jsend" "in" (http-get-request url #f)))
      (define state (port-recv state-port))
      (sched (msg-stop))

      (check-true (hash-has-key? state 'request) "got http request")
      (match-define (http-get-request got-url _) (hash-ref state 'request))
      (check-equal? got-url url "got correct url")
      (check-true (hash-has-key? state 'jsend-response) "got jsend response")
      (match-define (list response1 response2) (hash-ref state 'jsend-response))
      (match-define (json-data response1-data) response1)
      (check-equal? response1-data "hello world" "got the unwrapped message")
      (check-equal? response2 eof "got eof after message")))
