#lang racket/base

(provide make-scheduler (struct-out scheduler))

(require racket/async-channel)
(require racket/exn)

(require racket/match)
(require racket/function)
(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/loader)
(require fractalide/modules/rkt/rkt-fbp/port)
(require fractalide/modules/rkt/rkt-fbp/def)

; TODO : make sender that cannot read the channel
; TODO : make an helper function to change a agent-state, will be more clear

(struct agent-state (state number-ips is-running))

(struct scheduler (agents number-running will-stop mail-box))

; (-> scheduler Msg scheduler)
(define (scheduler-match self msg)
  (match msg
      [(msg-add-agent name type)
       (let* ([path type]
              [agt (load-agent path)]
              [agt (make-agent agt name (scheduler-mail-box self))]
              [old-agent (scheduler-agents self)]
              [agt-state (agent-state agt 0 #f)]
              [new-agents (hash-set old-agent name agt-state)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-remove-agent name)
       (let ([new-agents (hash-remove (scheduler-agents self) name)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-connect out port-out in port-in)
       (let* ([agents (scheduler-agents self)]
              [in-agt-state (hash-ref agents in)]
              [in-agt (agent-state-state in-agt-state)]
              [port (hash-ref (agent-inport in-agt) port-in)]
              [out-agt-state (hash-ref agents out)]
              [out-agt (agent-state-state out-agt-state)]
              [new-out-agt (agent-connect out-agt port-out port)]
              [new-agent-state (struct-copy agent-state out-agt-state [state new-out-agt])]
              [new-agents (hash-set agents out new-agent-state)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-connect-array-to out port-out selection in port-in)
       (let* ([agents (scheduler-agents self)]
              [in-sched-agt (hash-ref agents in)]
              [in-agt (agent-state-state in-sched-agt)]
              [sender (hash-ref (agent-inport in-agt) port-in)]
              [out-sched-agt (hash-ref agents out)]
              [out-agt (agent-state-state out-sched-agt)]
              [new-out-agt (agent-connect-array-to out-agt port-out selection sender)]
              [new-out-sched-agt (struct-copy agent-state out-sched-agt [state new-out-agt])]
              [new-agents (hash-set agents out new-out-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-connect-to-array out port-out in port-in selection)
       (let*-values
           ([(agents) (scheduler-agents self)]
            [(in-sched-agt) (hash-ref agents in)]
            [(in-agt) (agent-state-state in-sched-agt)]
            [(sender new-in-agt) (agent-connect-to-array in-agt port-in selection in (scheduler-mail-box self))]
            [(new-in-sched-agt) (struct-copy agent-state in-sched-agt [state new-in-agt])]
            [(out-sched-agt) (hash-ref agents out)]
            [(out-agt) (agent-state-state out-sched-agt)]
            [(new-out-agt) (agent-connect out-agt port-out sender)]
            [(new-out-sched-agt) (struct-copy agent-state out-sched-agt [state new-out-agt])]
            [(new-agents) (hash-set agents in new-in-sched-agt)]
            [(new-agents) (hash-set new-agents out new-out-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-connect-array-to-array out port-out selection-out in port-in selection-in)
       (let*-values
           ([(agents) (scheduler-agents self)]
            [(in-sched-agt) (hash-ref agents in)]
            [(in-agt) (agent-state-state in-sched-agt)]
            [(sender new-in-agt) (agent-connect-to-array in-agt port-in selection-in in (scheduler-mail-box self))]
            [(new-in-sched-agt) (struct-copy agent-state in-sched-agt [state new-in-agt])]
            [(out-sched-agt) (hash-ref agents out)]
            [(out-agt) (agent-state-state out-sched-agt)]
            [(new-out-agt) (agent-connect-array-to out-agt port-out selection-out sender)]
            [(new-out-sched-agt) (struct-copy agent-state out-sched-agt [state new-out-agt])]
            [(new-agents) (hash-set agents in new-in-sched-agt)]
            [(new-agents) (hash-set new-agents out new-out-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-disconnect out port-out)
       (let* ([agents (scheduler-agents self)]
              [out-agt-state (hash-ref agents out)]
              [out-agt (agent-state-state out-agt-state)]
              [new-out-agt (agent-disconnect out-agt port-out)]
              [new-agent-state (struct-copy agent-state out-agt-state [state new-out-agt])]
              [new-agents (hash-set agents out new-agent-state)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-disconnect-array-to out port-out selection)
       (let* ([agents (scheduler-agents self)]
              [out-sched-agt (hash-ref agents out)]
              [out-agt (agent-state-state out-sched-agt)]
              [new-out-agt (agent-disconnect-array-to out-agt port-out selection)]
              [new-out-sched-agt (struct-copy agent-state out-sched-agt [state new-out-agt])]
              [new-agents (hash-set agents out new-out-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-disconnect-to-array out port-out in port-in selection)
       (let* ([agents (scheduler-agents self)]
              [in-sched-agt (hash-ref agents in)]
              [in-agt (agent-state-state in-sched-agt)]
              [new-in-agt (agent-disconnect-to-array in-agt port-in selection)]
              [new-in-sched-agt (struct-copy agent-state in-sched-agt [state new-in-agt])]
              [out-sched-agt (hash-ref agents out)]
              [out-agt (agent-state-state out-sched-agt)]
              [new-out-agt (agent-disconnect out-agt port-out)]
              [new-out-sched-agt (struct-copy agent-state out-sched-agt [state new-out-agt])]
              [new-agents (hash-set agents in new-in-sched-agt)]
              [new-agents (hash-set new-agents out new-out-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-disconnect-array-to-array out port-out selection-out in port-in selection-in)
       (let* ([agents (scheduler-agents self)]
              [in-sched-agt (hash-ref agents in)]
              [in-agt (agent-state-state in-sched-agt)]
              [new-in-agt (agent-disconnect-to-array in-agt port-in selection-in)]
              [new-in-sched-agt (struct-copy agent-state in-sched-agt [state new-in-agt])]
              [out-sched-agt (hash-ref agents out)]
              [out-agt (agent-state-state out-sched-agt)]
              [new-out-agt (agent-disconnect-array-to out-agt port-out selection-out)]
              [new-out-sched-agt (struct-copy agent-state out-sched-agt [state new-out-agt])]
              [new-agents (hash-set agents in new-in-sched-agt)]
              [new-agents (hash-set new-agents out new-out-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-raw-connect out port-out sender)
       (let* ([agents (scheduler-agents self)]
              [out-agt-state (hash-ref agents out)]
              [out-agt (agent-state-state out-agt-state)]
              [new-out-agt (agent-connect out-agt port-out sender)]
              [new-agent-state (struct-copy agent-state out-agt-state [state new-out-agt])]
              [new-agents (hash-set agents out new-agent-state)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-mesg agt port mesg)
       (let* ([agents (scheduler-agents self)]
              [in-agt-state (hash-ref agents agt)]
              [in-agt (agent-state-state in-agt-state)]
              [port (hash-ref (agent-inport in-agt) port)]
              )
         (port-send port mesg)
         self)]
      [(msg-inc-ip agt)
       (let* ([agents (scheduler-agents self)]
              [agt-state (hash-ref agents agt)]
              [nbr (agent-state-number-ips agt-state)]
              [new-agt-state (struct-copy agent-state agt-state [number-ips (+ nbr 1)])]
              [new-agents (hash-set agents agt new-agt-state)]
              [new-self (struct-copy scheduler self [agents new-agents])])
         ; Increase number of saved IP
         (exec-agent new-self agt))]
      [(msg-dec-ip agt)
       (let* ([agents (scheduler-agents self)]
              [agt-state (hash-ref agents agt)]
              [nbr (agent-state-number-ips agt-state)]
              [new-agt-state (struct-copy agent-state agt-state [number-ips (- nbr 1)])]
              [new-agents (hash-set agents agt new-agt-state)]
              [new-self (struct-copy scheduler self [agents new-agents])])
         new-self)]
      [(msg-run-end agt-name)
       (let* ([agents (scheduler-agents self)]
              [nbr-running (scheduler-number-running self)]
              [agt-state (hash-ref agents agt-name)]
              [new-agt-state (struct-copy agent-state agt-state [is-running #f])]
              [new-agents (hash-set agents agt-name new-agt-state)]
              [new-state (struct-copy scheduler self [agents new-agents]
                                      [number-running (- nbr-running 1)])]
              [new-state (exec-agent new-state agt-name)]
              [nbr-running (scheduler-number-running new-state)]
              [stop? (scheduler-will-stop new-state)])
         new-state)]
      [(msg-start)
       (define new-self (for/fold
                            ([acc self])
                            ([(name agt) (scheduler-agents self)])
                          (if (agent-no-input? (agent-state-state agt))
                              (exec-agent acc name #t)
                              acc)))
       new-self]
      [(msg-start-agent agt)
         (exec-agent self agt #t)]
      [(msg-update-agent agt proc)
       (let* ([agents (scheduler-agents self)]
              [sched-agt (hash-ref agents agt)]
              [state (agent-state-state sched-agt)]
              [new-state (proc state)]
              [new-sched-agt (struct-copy agent-state sched-agt [state new-state])]
              [new-agents (hash-set agents agt new-sched-agt)])
         (struct-copy scheduler self [agents new-agents]))]
      [(msg-stop)
       (struct-copy scheduler self [will-stop #t])]
      [(msg-display) (displayln self) self]
      [else (display "unknown msg : ") (displayln msg)
            self]))

; (-> scheduler Void)
(define (scheduler-loop self)
  (let ([msg (async-channel-try-get (scheduler-mail-box self))])
    (cond
      [msg
       (scheduler-loop (scheduler-match self msg))]
      [(and (scheduler-will-stop self) (= (scheduler-number-running self) 0))
       (void)]
      [else
       (scheduler-loop (scheduler-match self (async-channel-get (scheduler-mail-box self))))])))

; (->* (scheduler String) (Boolean) scheduler)
(define (exec-agent state agt-name [force? #f])
  ; Look if the agent have to run (not running yet and at least one IP)
  (let* ([agents (scheduler-agents state)]
         [sched (scheduler-mail-box state)]
         [agt-state (hash-ref agents agt-name)]
         [is-running (agent-state-is-running agt-state)]
         [agt (agent-state-state agt-state)]
         [proc (agent-proc agt)]
         [nbr-ips (agent-state-number-ips agt-state)]
         [nbr-running (scheduler-number-running state)])
    (if (and (not is-running) (or force? (> nbr-ips 0)))
        ;true -> must run
        ; change is-running to true and exec
        (begin
          (thread (lambda ()
                    (with-handlers ([exn:fail?
                                    (lambda (e) (eprintf "in agent ~a:~n~a" agt-name (exn->string e)))])
                      (proc
                       ((curry get-in) agt)
                       ((curry get-out) agt)
                       ((curry get-in-array) agt)
                       ((curry get-out-array) agt)))
                    (async-channel-put sched (msg-run-end agt-name))))
          (let* ([new-agt-state (struct-copy agent-state agt-state [is-running #t]
                                              [state agt])]
               [new-agents (hash-set agents agt-name new-agt-state)]
               [new-state (struct-copy scheduler state [agents new-agents]
                                       [number-running (+ 1 nbr-running)])])
          new-state))
        ;false -> do nothing
        state)))

; (-> False (-> Msg Void))
(define (make-scheduler opt)
  (let* ([mail-box (make-async-channel)]
         [state (scheduler #hash() 0 #f mail-box)]
         [t (thread (lambda() (scheduler-loop state)))])
    (lambda msgs
      (for ([msg msgs])
        (async-channel-put mail-box msg)
        (match msg
          [(msg-stop) (thread-wait t)]
          [else (void)])))))
