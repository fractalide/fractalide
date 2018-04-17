#lang typed/racket

(provide port make-port port-send port-recv port-try-recv)

(require typed/racket/async-channel)
(require fractalide/modules/rkt/rkt-fbp/msg)

(struct port([channel : (Async-Channelof Any)]
             [name : String ]
             [thd : Thread]))

(: make-port (-> Exact-Positive-Integer String Thread port))
(define (make-port size name thd)
    (port (make-async-channel size) name thd))

(: port-send (-> port Any Void))
(define (port-send self msg)
  (async-channel-put (port-channel self) msg)
  (thread-send (port-thd self) (msg-inc-ip (port-name self))))

(: port-recv (-> port Any))
(define (port-recv self)
  (thread-send (port-thd self) (msg-dec-ip (port-name self)))
  (async-channel-get (port-channel self)))

(: port-try-recv (-> port Any))
(define (port-try-recv self)
  (let ([msg (async-channel-try-get (port-channel self))])
    (if msg
        (begin
          (thread-send (port-thd self) (msg-dec-ip (port-name self)))
          msg)
        #f)))
