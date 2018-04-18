#lang typed/racket

(require fractalide/modules/rkt/rkt-fbp/scheduler)
(require fractalide/modules/rkt/rkt-fbp/msg)

(define sched (make-scheduler #f))
(sched (msg-add-agent "adder" "add"))
(sched (msg-add-agent "displayer" "disp"))
(sched (msg-add-agent "displayer" "disp1"))
(sched (msg-add-agent "clone" "clone"))
(sched (msg-connect "add" "out" "disp" "in"))
(sched (msg-connect-array-to-array "clone" "out" "1" "add" "in" "1"))
(sched (msg-connect-array-to "clone" "out" "2" "disp1" "in"))
(sched (msg-connect-to-array "disp1" "out" "add" "in" "2"))

(sched (msg-iip "clone" "in" 5))

(sched (msg-add-agent "accumulator" "acc"))
(sched (msg-iip "acc" "acc" 0))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))
(sched (msg-iip "acc" "in" 2))

(sleep 0.5)
(sched (msg-stop))
