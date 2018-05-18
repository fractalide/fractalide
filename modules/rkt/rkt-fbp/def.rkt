#lang racket/base

(provide (all-defined-out)
         (struct-out agent))

(struct agent (inport in-array-port outport out-array-port proc option))

(struct opt-agent (inport in-array outport out-array proc))

(struct port (channel name thd sync? option))

; All sched messages

(struct msg-set-scheduler-thread (t))
(struct msg-add-agent (name type))
(struct msg-remove-agent (name))
(struct msg-connect (out port-out in port-in))
(struct msg-connect-array-to (out port-out selection in port-in))
(struct msg-connect-to-array (out port-out in port-in selection))
(struct msg-connect-array-to-array (out port-out selection-out in port-in selection-in))
(struct msg-disconnect (out port-out))
(struct msg-disconnect-array-to (out port-out selection))
(struct msg-disconnect-to-array (out port-out in port-in selection))
(struct msg-disconnect-array-to-array (out port-out selection-out in port-in selection-in))
(struct msg-raw-connect (out port-out sender))
(struct msg-mesg (agt port mesg))
(struct msg-inc-ip (agt))
(struct msg-dec-ip (agt))
(struct msg-run-end (agt))
(struct msg-display ())
(struct msg-start ())
(struct msg-start-agent (agt))
(struct msg-update-agent(agt proc))
(struct msg-stop ())
(struct msg-run (agt))
