#lang typed/racket

(provide (all-defined-out))

(struct msg-set-scheduler-thread ([t : Thread]))
(struct msg-add-agent ([type : String] [name : String]))
(struct msg-connect ([out : String][port-out : String][in : String][port-in : String]))
(struct msg-iip ([agt : String][port : String][iip : Any]))
(struct msg-inc-ip ([agt : String]))
(struct msg-dec-ip ([agt : String]))
(struct msg-run-end ([agt : String]))
(struct msg-display ())
(struct msg-quit ())
(struct msg-stop ())
(struct msg-run ([agt : String]))
(define-type Msg (U msg-set-scheduler-thread
                    msg-add-agent
                    msg-connect
                    msg-iip
                    msg-inc-ip
                    msg-dec-ip
                    msg-run-end
                    msg-display
                    msg-quit
                    msg-stop
                    msg-run))
