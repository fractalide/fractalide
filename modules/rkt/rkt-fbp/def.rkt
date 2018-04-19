#lang typed/racket/base

(provide (all-defined-out))

(define-type in-array-port
  (Immutable-HashTable String (cons Integer port)))

(define-type out-array-port
  (Immutable-HashTable String port))

(struct agent([inport : (Immutable-HashTable String port)]
              [in-array-port : (Immutable-HashTable String in-array-port)]
              [outport : (Immutable-HashTable String (U False port))]
              [out-array-port : (Immutable-HashTable String out-array-port)]
              [proc : (-> (-> String port)
                          (-> String (U False port))
                          (-> String in-array-port)
                          (-> String out-array-port)
                          Any ; the option
                          Void)]
              [option : Any]) #:transparent)

(struct opt-agent([inport : (Listof String)]
                  [in-array : (Listof String)]
                  [outport : (Listof String)]
                  [out-array : (Listof String)]
                  [proc : (-> (-> String port)
                              (-> String (U False port))
                              (-> String in-array-port)
                              (-> String out-array-port)
                              Any ; the option
                              Void)]) #:transparent)

(struct port([channel : (Async-Channelof Any)]
             [name : String]
             [thd : (Async-Channelof Msg)]
             [sync? : Boolean]))

; All sched messages

(struct msg-set-scheduler-thread ([t : Thread]))
(struct msg-add-agent ([type : String] [name : String]))
(struct msg-remove-agent ([name : String]))
(struct msg-connect ([out : String][port-out : String][in : String][port-in : String]))
(struct msg-connect-array-to ([out : String][port-out : String][selection : String]
                                            [in : String][port-in : String]))
(struct msg-connect-to-array ([out : String][port-out : String]
                                            [in : String][port-in : String][selection : String]))
(struct msg-connect-array-to-array ([out : String][port-out : String][selection-out : String]
                                            [in : String][port-in : String][selection-in : String]))
(struct msg-disconnect ([out : String][port-out : String]))
(struct msg-disconnect-array-to ([out : String][port-out : String][selection : String]))
(struct msg-disconnect-to-array ([out : String][port-out : String]
                                 [in : String][port-in : String][selection : String]))
(struct msg-disconnect-array-to-array ([out : String][port-out : String][selection-out : String]
                                                  [in : String][port-in : String][selection-in : String]))
(struct msg-iip ([agt : String][port : String][iip : Any]))
(struct msg-inc-ip ([agt : String]))
(struct msg-dec-ip ([agt : String]))
(struct msg-run-end ([agt : String]))
(struct msg-display ())
(struct msg-start ())
(struct msg-start-agent ([agt : String]))
(struct msg-update-agent([agt : String][proc : (-> agent agent)]))
(struct msg-stop ())
(struct msg-run ([agt : String]))
(define-type Msg (U msg-set-scheduler-thread
                    msg-add-agent
                    msg-remove-agent
                    msg-connect
                    msg-connect-array-to msg-connect-to-array msg-connect-array-to-array
                    msg-disconnect
                    msg-disconnect-array-to msg-disconnect-to-array msg-disconnect-array-to-array
                    msg-iip
                    msg-inc-ip
                    msg-dec-ip
                    msg-run-end
                    msg-display
                    msg-start msg-start-agent
                    msg-update-agent
                    msg-stop
                    msg-run))
