#lang typed/racket

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
             [thd : Thread]
             [sync? : Boolean]))
