#lang typed/racket

; (provide make-scheduler (struct-out scheduler))
(provide make-scheduler (struct-out scheduler))

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)
(require fractalide/modules/rkt/rkt-fbp/msg)

(require/typed fractalide/modules/rkt/rkt-fbp/loader
  [load-agent (-> String opt-agent)])

; TODO : make sender that cannot read the channel

(struct agent-state([state : agent]
                    [number-ips : Integer] ; Check for Integer -> Natural
                    [is-running : Boolean]) #:transparent)

(struct scheduler([agents : (Immutable-HashTable String agent-state)]
                  [number-running : Integer]
                  [will-stop : Boolean]) #:transparent)

(: scheduler-loop (-> scheduler Void))
(define (scheduler-loop self)
  (let ([msg (thread-receive)])
    (match msg
      [(msg-add-agent type name)
       (let* ([path (string-append "./agents/" type ".rkt")]
              [agt (load-agent path)]
              [agt (make-agent agt name (current-thread))]
              [old-agent (scheduler-agents self)]
              [agt-state (agent-state agt 0 #f)]
              [new-agents (hash-set old-agent name agt-state)])
         (scheduler-loop (struct-copy scheduler self [agents new-agents])))]
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
         (scheduler-loop (struct-copy scheduler self [agents new-agents])))]
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
         (scheduler-loop (struct-copy scheduler self [agents new-agents])))]
      [(msg-connect-to-array out port-out in port-in selection)
       (let*-values
           ([(agents) (scheduler-agents self)]
            [(in-sched-agt) (hash-ref agents in)]
            [(in-agt) (agent-state-state in-sched-agt)]
            [(sender new-in-agt) (agent-connect-to-array in-agt port-in selection in (current-thread))]
            [(new-in-sched-agt) (struct-copy agent-state in-sched-agt [state new-in-agt])]
            [(out-sched-agt) (hash-ref agents out)]
            [(out-agt) (agent-state-state out-sched-agt)]
            [(new-out-agt) (agent-connect out-agt port-out sender)]
            [(new-out-sched-agt) (struct-copy agent-state out-sched-agt [state new-out-agt])]
            [(new-agents) (hash-set agents in new-in-sched-agt)]
            [(new-agents) (hash-set new-agents out new-out-sched-agt)])
         (scheduler-loop (struct-copy scheduler self [agents new-agents])))]
      [(msg-connect-array-to-array out port-out selection-out in port-in selection-in)
       (let*-values
           ([(agents) (scheduler-agents self)]
            [(in-sched-agt) (hash-ref agents in)]
            [(in-agt) (agent-state-state in-sched-agt)]
            [(sender new-in-agt) (agent-connect-to-array in-agt port-in selection-in in (current-thread))]
            [(new-in-sched-agt) (struct-copy agent-state in-sched-agt [state new-in-agt])]
            [(out-sched-agt) (hash-ref agents out)]
            [(out-agt) (agent-state-state out-sched-agt)]
            [(new-out-agt) (agent-connect-array-to out-agt port-out selection-out sender)]
            [(new-out-sched-agt) (struct-copy agent-state out-sched-agt [state new-out-agt])]
            [(new-agents) (hash-set agents in new-in-sched-agt)]
            [(new-agents) (hash-set new-agents out new-out-sched-agt)])
         (scheduler-loop (struct-copy scheduler self [agents new-agents])))]
      [(msg-iip agt port iip)
       (let* ([agents (scheduler-agents self)]
              [in-agt-state (hash-ref agents agt)]
              [in-agt (agent-state-state in-agt-state)]
              [port (hash-ref (agent-inport in-agt) port)]
              )
         (port-send port iip)
         (scheduler-loop self))]
      [(msg-inc-ip agt)
       (let* ([agents (scheduler-agents self)]
              [agt-state (hash-ref agents agt)]
              [nbr (agent-state-number-ips agt-state)]
              [new-agt-state (struct-copy agent-state agt-state [number-ips (+ nbr 1)])]
              [new-agents (hash-set agents agt new-agt-state)]
              [new-self (struct-copy scheduler self [agents new-agents])])
         ; Increase number of saved IP
         (scheduler-loop (exec-agent new-self agt)))]
      [(msg-dec-ip agt)
       (let* ([agents (scheduler-agents self)]
              [agt-state (hash-ref agents agt)]
              [nbr (agent-state-number-ips agt-state)]
              [new-agt-state (struct-copy agent-state agt-state [number-ips (- nbr 1)])]
              [new-agents (hash-set agents agt new-agt-state)]
              [new-self (struct-copy scheduler self [agents new-agents])])
         (scheduler-loop new-self))]
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
         (if (and stop? (= nbr-running 0))
             (void)
             (scheduler-loop new-state)))]
      [(msg-stop)
       (if (= (scheduler-number-running self) 0)
           (void)
           (scheduler-loop (struct-copy scheduler self [will-stop #t])))]
      [(msg-display) (displayln self) (scheduler-loop self)]
      [(msg-quit) (displayln "Scheduler shut down")]
      [else (display "unknown msg : ") (displayln msg)
            (scheduler-loop self)])))

(: exec-agent (-> scheduler String scheduler))
(define (exec-agent state agt-name)
  ; Look if the agent have to run (not running yet and at least one IP)
  (let* ([agents (scheduler-agents state)]
         [sched (current-thread)]
         [agt-state (hash-ref agents agt-name)]
         [is-running (agent-state-is-running agt-state)]
         [agt (agent-state-state agt-state)]
         [proc (agent-proc agt)]
         [nbr-ips (agent-state-number-ips agt-state)]
         [nbr-running (scheduler-number-running state)])
    (if (and (not is-running) (> nbr-ips 0))
        ;true -> must run
        ; change is-running to true and exec
        (begin
          (thread (lambda ()
                    (proc
                     ((curry get-in) agt)
                     ((curry get-out) agt)
                     ((curry get-in-array) agt)
                     ((curry get-out-array) agt))
                    (thread-send sched (msg-run-end agt-name))))
          (let* ([new-agt-state (struct-copy agent-state agt-state [is-running #t])]
               [new-agents (hash-set agents agt-name new-agt-state)]
               [new-state (struct-copy scheduler state [agents new-agents]
                                       [number-running (+ 1 nbr-running)])])
          new-state))
        ;false -> do nothing
        state)))

(: make-scheduler (-> False (-> Msg Void)))
(define (make-scheduler opt)
  (let* ([state (scheduler #hash() 0 #f)]
         [t (thread (lambda() (scheduler-loop state)))])
    (lambda (msg)
      (thread-send t msg)
      (match msg
        [(msg-stop) (thread-wait t)]
        [else (void)]))))
