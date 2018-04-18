#lang typed/racket/base

(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require fractalide/modules/rkt/rkt-fbp/msg)
(require fractalide/modules/rkt/rkt-fbp/def)
(require fractalide/modules/rkt/rkt-fbp/agent)

(define sched (make-scheduler #f))
(sched (msg-add-agent "adder" "add"))
(sched (msg-add-agent "displayer" "disp"))
(sched (msg-add-agent "displayer" "disp1"))
(sched (msg-add-agent "clone" "clone"))
(sched (msg-add-agent "dummy" "dummy"))
(sched (msg-add-agent "clone" "useless-clone-for-start"))
(sched (msg-connect "add" "out" "disp" "in"))
(sched (msg-connect-array-to-array "clone" "out" "1" "add" "in" "1"))
(sched (msg-connect-array-to "clone" "out" "2" "disp1" "in"))
(sched (msg-connect-to-array "disp1" "out" "add" "in" "2"))
(sched (msg-start))

(sched (msg-add-agent "accumulator" "acc"))
(sched (msg-iip "acc" "acc" 0))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))

(sched (msg-iip "disp1" "option" "never"))
(sched (msg-iip "disp1" "option" "see"))
(sched (msg-iip "disp1" "option" "this"))
(sleep 0.5)
(sched (msg-iip "disp1" "option" "disp1 : "))
(sched (msg-iip "disp" "option" "Disp received a msg : "))

; everything connected
(sched (msg-iip "clone" "in" 5))

(sleep 1)
(displayln "-- add must out 5")
(sleep 1)
; Test disconnect : Add must out 5
(sched (msg-disconnect-to-array "disp1" "out" "add" "in" "2"))
(sched (msg-iip "clone" "in" 5))

(sleep 1)
(displayln "-- no more add")
(sleep 1)
; No more add
(sched (msg-disconnect-array-to-array "clone" "out" "1" "add" "in" "1"))
(sched (msg-iip "clone" "in" 5))


(sleep 1)
(displayln "-- no more disp1 msg")
(sleep 1)
; No more disp1 msg
(sched (msg-disconnect-array-to "clone" "out" "2"))
(sched (msg-iip "clone" "in" 5))

(sleep 1)
(displayln "-- disp1 before change")
(sleep 1)
(sched (msg-iip "disp1" "in" "a beautiful msg"))
(sleep 1)
(sched (msg-update-agent "disp1"
                         (lambda (agt)
                           (struct-copy agent agt [proc
                                                   (lambda ([i : (-> String port)]
                                                            [o : (-> String (U False port))]
                                                            [ia : (-> String in-array-port)]
                                                            [io : (-> String out-array-port)]
                                                            [opt : Any])
                                                     (recv (i "in"))
                                                     (displayln "After change!"))]))))
(sleep 1)
(displayln "-- disp1 after change")
(sleep 1)
(sched (msg-iip "disp1" "in" "a beautiful msg"))


(sleep 0.5)
(sched (msg-stop))
