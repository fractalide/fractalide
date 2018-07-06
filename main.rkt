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
    #:input '("recv-request" "recv-response")
    #:output '("send-request" "send-response")
    #:proc
    (lambda (input output input-array output-array)

(define (do-get-request url accept)
  (send (output "send-request")
        (http-get-request (url->string url) (if accept accept #"application/json")))
  (define response (recv (input "recv-response")))
  (match response
    [(http-error _) (send (output "send-response") response)]
    [(http-response status headers data)
     (define jsexpr (with-input-from-bytes data read-json))
     (match jsexpr
       [(hash-table ('status "fail") ('data data))
        (send (output "send-response") (json-fail data))]
       [(hash-table ('status "error"))
        (send (output "send-response")
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
          (send (output "send-response")
                (json-data elem)))
        (if (> total-pages page)
            (do-get-request (url-with-page url (+ 1 (string->number page))) accept)
            (send (output "send-response") eof))]
       [(hash-table ('status "success") ('data data))
        (send (output "send-response" (json-data data)))
        (send (output "send-response" eof))])]))

      (define request (recv (input "recv-request")))
      (match-define (http-get-request url accept) request) 
      (do-get-request (string->url url) accept))))

(module+ test
  (require syntax/location)
  (dynamic-require (quote (submod paging-jsend-get/test main)) #f))
