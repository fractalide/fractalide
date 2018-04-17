#lang typed/racket

(require rkt-fbp/scheduler)
(require rkt-fbp/msg)

(define sched (make-scheduler #f))
(sched (msg-add-agent "adder" "add"))
(sched (msg-add-agent "displayer" "disp"))
(sched (msg-connect "add" "out" "disp" "in"))

(sched (msg-iip "add" "in" 5))
(sched (msg-iip "add" "in" 3))

(sleep 0.5)
