#lang racket/base

(provide port make-port port-send port-recv port-try-recv)

(require racket/async-channel)
(require fractalide/modules/rkt/rkt-fbp/def)

; (-> Exact-Positive-Integer String (Async-Channelof Msg) Boolean port)
(define (make-port size name thd sync? #:option [option #f])
    (port (make-async-channel size) name thd sync? option))

; (-> port Any Void)
(define (port-send self msg)
  (async-channel-put (port-channel self) msg)
  (if (port-sync? self)
      (async-channel-put (port-thd self) (msg-inc-ip (port-name self)))
      (void)))

; (-> port Any)
(define (port-recv self)
  (if (port-option self)
      (recv-option self #f #t)
      (begin
        (if (port-sync? self)
            (async-channel-put (port-thd self) (msg-dec-ip (port-name self)))
            (void))
        (async-channel-get (port-channel self)))))

; (-> port Any)
(define (port-try-recv self)
  (if (port-option self)
      (recv-option self #f)
      (let ([msg (async-channel-try-get (port-channel self))])
        (if msg
            (begin
              (if (port-sync? self)
                  (async-channel-put (port-thd self) (msg-dec-ip (port-name self)))
                  (void))
              msg)
            #f))))

; (-> port Any)
(define (recv-option self acc (force? #f))
  (let* ([msg (if force?
                  (async-channel-get (port-channel self))
                  (async-channel-try-get (port-channel self)))])
    (if msg
        (recv-option self msg)
        (if acc
            (begin
              (async-channel-put (port-channel self) acc)
              acc)
            #f))))
