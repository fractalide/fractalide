#lang racket/base

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent
         (prefix-in g: fractalide/modules/rkt/rkt-fbp/graph)
         fractalide/modules/rkt/rkt-fbp/def)

(require racket/match)

; TODO : manage well recursive virtual array (not all deleted for the moment)

(define agt (define-agent
              #:input '("in" "flat") ; in port
              #:output '("sched" "flat" "out" "halt") ; out port
              #:proc (lambda (input output input-array output-array option)
                       (let* ([try-acc (try-recv (input "acc"))]
                              [acc (if try-acc try-acc (g:graph '() '() '() '() '()))]
                              [msg (recv (input "in"))])
                         (define new-acc
                           (match msg
                             [(vector "add" add)
                              (define flat (send-sched add acc input output))
                              (struct-copy g:graph acc
                                           [agent (append (g:graph-agent acc) (g:graph-agent flat))]
                                           [edge (append (g:graph-edge acc) (g:graph-edge flat))]
                                           ; The virtuals were already merged in send-sched -> resolve-virtual
                                           [virtual-in (g:graph-virtual-in flat)]
                                           [virtual-out (g:graph-virtual-out flat)])]
                             [(vector "dynamic-add" graph port)
                              ; do a classic add with the sender "port"
                              (define flat (send-sched graph acc input output port))
                              (struct-copy g:graph acc
                                           [agent (append (g:graph-agent acc) (g:graph-agent flat))]
                                           [edge (append (g:graph-edge acc) (g:graph-edge flat))]
                                           ; The virtuals were already merged in send-sched -> resolve-virtual
                                           [virtual-in (g:graph-virtual-in flat)]
                                           [virtual-out (g:graph-virtual-out flat)])]
                             [(vector "dynamic-remove" graph)
                              (send-sched-remove graph acc input output)]
                             ["stop"
                              (send (output "halt") #t)
                              (send (output "sched") (msg-stop))
                              acc]))
                         (send (output "acc") new-acc)))))

(define (send-sched-remove rem actual input output)
  ; Flat the graph
  (send (output "flat") rem)
  (define flat (recv (input "flat")))
  (define flat-virtual (struct-copy g:graph flat [virtual-in (append (g:graph-virtual-in actual) (g:graph-virtual-in flat))]
                                    [virtual-out (append (g:graph-virtual-out actual) (g:graph-virtual-out flat))]))
  (define rem-flat (resolve-virtual flat-virtual))
  ; Manage the Scheduler
  (for ([edge (g:graph-edge rem-flat)])
    (match edge
      [(g:g-edge out p-out #f in p-in #f)
       (send (output "sched") (msg-disconnect out p-out))]
      [(g:g-edge out p-out s-out in p-in #f)
       (send (output "sched") (msg-disconnect-array-to out p-out s-out))]
      [(g:g-edge out p-out #f in p-in s-in)
       (send (output "sched") (msg-disconnect-to-array out p-out in p-in s-in))]
      [(g:g-edge out p-out s-out in p-in s-in)
       (send (output "sched") (msg-disconnect-array-to-array out p-out s-out in p-in s-in))]))
  (for ([agent (g:graph-agent rem-flat)])
    (send (output "sched") (msg-remove-agent (g:g-agent-name agent))))
  ; Remove in the actual
  (define new-agent (for/fold ([new-a (g:graph-agent actual)])
                              ([agt (g:graph-agent rem-flat)])
                      (remove agt new-a)))
  (define new-edge (for/fold ([new-a (g:graph-edge actual)])
                             ([edg (g:graph-edge rem-flat)])
                     (remove edg new-a)))
  (define new-v-out (filter (lambda (virt)
                              (not (for/or ([agt (g:graph-agent rem-flat)])
                                     (string=? (g:g-agent-name agt) (g:g-virtual-agent virt)))))
                            (g:graph-virtual-out actual)))
  (define new-v-in (filter (lambda (virt)
                             (not (for/or ([agt (g:graph-agent rem-flat)])
                                    (string=? (g:g-agent-name agt) (g:g-virtual-agent virt)))))
                           (g:graph-virtual-in actual)))
  (struct-copy g:graph actual [virtual-in (reverse new-v-in)]
               [virtual-out (reverse new-v-out)]
               [edge new-edge]
               [agent new-agent]))

(define (send-sched add actual input output [sender #f])
  ; Flat the graph
  (send (output "flat") add)
  (define flat (recv (input "flat")))
  (define flat-virtual (struct-copy g:graph flat [virtual-in (append (g:graph-virtual-in actual) (g:graph-virtual-in flat))]
                                    [virtual-out (append (g:graph-virtual-out actual) (g:graph-virtual-out flat))]))
  (define add-flat (resolve-virtual flat-virtual))
  ; Add the agent
  (for ([agent (g:graph-agent add-flat)])
    (send (output "sched") (msg-add-agent (g:g-agent-name agent) (g:g-agent-type agent))))
  (for ([edge (g:graph-edge add-flat)])
    (match edge
      [(g:g-edge out p-out #f in p-in #f)
       (send (output "sched") (msg-connect out p-out in p-in))]
      [(g:g-edge out p-out s-out in p-in #f)
       (send (output "sched") (msg-connect-array-to out p-out s-out in p-in))]
      [(g:g-edge out p-out #f in p-in s-in)
       (send (output "sched") (msg-connect-to-array out p-out in p-in s-in))]
      [(g:g-edge out p-out s-out in p-in s-in)
       (send (output "sched") (msg-connect-array-to-array out p-out s-out in p-in s-in))]))
  (if sender
      (for ([vo (g:graph-virtual-out flat)])
        (if (string=? "dynamic-out" (g:g-virtual-virtual-port vo))
            (let ([final-out (for/fold ([acc (cons (g:g-virtual-agent vo) (g:g-virtual-agent-port vo))])
                                       ([virt (g:graph-virtual-out add-flat)])
                               (if (and (string=? (car acc) (g:g-virtual-virtual-agent virt))
                                        (string=? (cdr acc) (g:g-virtual-virtual-port virt)))
                                   (cons (g:g-virtual-agent virt) (g:g-virtual-agent-port virt))
                                   acc))])
              (send (output "sched") (msg-raw-connect
                                      (car final-out)
                                      (cdr final-out)
                                      sender)))
            (void)))
      (void))
  (for ([iip (g:graph-iip add-flat)])
    (match iip
      [(g:g-iip in p-in iip)
       (send (output "sched") (msg-iip in p-in iip))]))
  add-flat)

; (-> (Listof virtual) (Listof virtual) graph graph)
(define (resolve-virtual actual-graph)
  ; virtual-in resolve
  (define res-edge
    (for/list ([edg (g:graph-edge actual-graph)])
      (define new-edge (for/fold ([acc edg])
                                 ([virt (g:graph-virtual-in actual-graph)])
                         (if (and (string=? (g:g-edge-in edg) (g:g-virtual-virtual-agent virt))
                                  (string=? (g:g-edge-port-in edg) (g:g-virtual-virtual-port virt)))
                             (struct-copy g:g-edge acc [in (g:g-virtual-agent virt)][port-in (g:g-virtual-agent-port virt)])
                             acc)))
      (for/fold ([acc new-edge])
                ([virt (g:graph-virtual-out actual-graph)])
        (if (and (string=? (g:g-edge-out edg) (g:g-virtual-virtual-agent virt))
                 (string=? (g:g-edge-port-out edg) (g:g-virtual-virtual-port virt)))
            (struct-copy g:g-edge acc [out (g:g-virtual-agent virt)][port-out (g:g-virtual-agent-port virt)])
            acc))))
  ; Iip resolve
  (define res-iip
    (for/list ([iip (g:graph-iip actual-graph)])
      (for*/fold ([acc iip])
                 ([virt (g:graph-virtual-in actual-graph)])
        (if (and (string=? (g:g-iip-in iip) (g:g-virtual-virtual-agent virt))
                 (string=? (g:g-iip-port-in iip) (g:g-virtual-virtual-port virt)))
            (struct-copy g:g-iip acc [in (g:g-virtual-agent virt)] [port-in (g:g-virtual-agent-port virt)])
            acc))))
  (struct-copy g:graph actual-graph [edge res-edge] [iip res-iip]))
