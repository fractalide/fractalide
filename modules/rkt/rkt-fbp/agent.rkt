#lang typed/racket

; TODO : what to do with unconnected output port?

(provide (struct-out agent) (struct-out opt-agent) make-agent recv send)

(require rkt-fbp/port)

(struct agent([inport : (Immutable-HashTable String port)]
              [outport : (Immutable-HashTable String (U False port))]
              [proc : (-> agent Void)]
              [sched : Thread]) #:transparent)

(struct opt-agent([inport : (Listof String)]
                  [outport : (Listof String)]
                  [proc : (-> agent Void)]) #:transparent)

(: recv (-> agent String Any))
(define (recv agent port)
  (port-recv (hash-ref (agent-inport agent) port)))

(: send (-> agent String Any Void))
(define (send agent port msg)
  (let ([out-port (hash-ref (agent-outport agent) port)])
    (if out-port
        (port-send out-port msg)
        (void))))

(: build-inport (-> (Listof String) String Thread (Immutable-HashTable String port)))
(define (build-inport inputs name sched)
  (for/hash: : (Immutable-HashTable String port) ([input inputs])
    (values input (make-port 10 name sched))))

(: build-outport (-> (Listof String) (Immutable-HashTable String False)))
(define (build-outport outputs)
  (for/hash: : (Immutable-HashTable String False) ([output outputs])
    (values output #f)))

(: make-agent (-> opt-agent String Thread agent))
(define (make-agent opt name sched)
  (agent
   (build-inport (opt-agent-inport opt) name sched)
   (build-outport (opt-agent-outport opt))
   (opt-agent-proc opt)
   sched)) ;TODO check if useful
