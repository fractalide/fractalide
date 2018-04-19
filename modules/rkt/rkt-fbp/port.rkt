#lang typed/racket/base

(provide port make-port port-send port-recv port-try-recv)

(require typed/racket/async-channel)
(require fractalide/modules/rkt/rkt-fbp/def)

(: make-port (-> Exact-Positive-Integer String (Async-Channelof Msg) Boolean port))
(define (make-port size name thd sync?)
    (port (make-async-channel size) name thd sync?))

(: port-send (-> port Any Void))
(define (port-send self msg)
  (async-channel-put (port-channel self) msg)
  (if (port-sync? self)
      (async-channel-put (port-thd self) (msg-inc-ip (port-name self)))
      (void)))

(: port-recv (-> port Any))
(define (port-recv self)
  (if (port-sync? self)
      (async-channel-put (port-thd self) (msg-dec-ip (port-name self)))
      (void))
  (async-channel-get (port-channel self)))

(: port-try-recv (-> port Any))
(define (port-try-recv self)
  (let ([msg (async-channel-try-get (port-channel self))])
    (if msg
        (begin
          (if (port-sync? self)
              (async-channel-put (port-thd self) (msg-dec-ip (port-name self)))
              (void))
          msg)
        #f)))
