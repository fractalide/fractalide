#lang typed/racket

; (provide make-scheduler (struct-out scheduler))
(provide make-scheduler (struct-out scheduler))

(require fractalide/modules/rkt/rkt-fbp/agent)
(require fractalide/modules/rkt/rkt-fbp/port)
(require fractalide/modules/rkt/rkt-fbp/msg)

(require/typed fractalide/modules/rkt/rkt-fbp/loader
  [load-agent (-> String opt-agent)])

; TODO : make sender that cannot read the channel
; TODO : remove thd in struct scheduler

(struct agent-state([state : agent]
                    [number-ips : Integer] ; Check for Integer -> Natural
                    [is-running : Boolean]) #:transparent)

(struct scheduler([agents : (Immutable-HashTable String agent-state)]
                  [number-running : Integer]
                  [will-stop : Boolean]
                  [thd : Thread]) #:transparent)

(: scheduler-loop (-> scheduler Void))
(define (scheduler-loop self)
  (let ([msg (thread-receive)])
    (match msg
      [(msg-set-scheduler-thread t)
       (scheduler-loop (struct-copy scheduler self [thd t]))]
      [(msg-add-agent type name)
       (let* ([path (string-append "./agents/" type ".rkt")]
              [agt (load-agent path)]
              [agt (make-agent agt name (scheduler-thd self))]
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
              [old-outport (agent-outport out-agt)]
              [new-outport (hash-set old-outport port-out port)]
              [new-out-agt (struct-copy agent out-agt [outport new-outport])]
              [new-agent-state (struct-copy agent-state out-agt-state [state new-out-agt])]
              [new-agents (hash-set agents out new-agent-state)])
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
         [sched (scheduler-thd state)]
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
                    (proc agt)
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
  (let* ([state (scheduler #hash() 0 #f (thread (lambda() (void))))]
         [t (thread (lambda() (scheduler-loop state)))])
    (thread-send t (msg-set-scheduler-thread t))
    (lambda (msg)
      (thread-send t msg)
      (match msg
        [(msg-stop) (thread-wait t)]
        [else (void)]))))
