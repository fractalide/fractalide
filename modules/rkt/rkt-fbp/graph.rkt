#lang racket

(provide (all-defined-out))

(require (for-syntax syntax/to-string))
(require syntax/to-string)

(require racket/match
         (for-syntax racket/match)
         (prefix-in agt: fractalide/modules/rkt/rkt-fbp/agent)
         fractalide/modules/rkt/rkt-fbp/def)

(struct graph (agent edge virtual-in virtual-out mesg) #:prefab)
(struct g-agent (name type) #:prefab)
(struct g-edge (out port-out selection-out in port-in selection-in) #:prefab)
(struct g-virtual (virtual-agent virtual-port agent agent-port) #:prefab)
(struct g-mesg (in port-in mesg) #:prefab)

(define-syntax node
  (lambda (stx)
    (syntax-case stx ()
      [(_ name ${type})
       #'(let ([t (syntax->string #'(type))])
           (g-agent name (string-append "${" t "}")))]
      [(_ name type)
       #'(g-agent name type)]
      )))

; (struct node (name type) #:prefab)
(struct edge (output output-port out-selection input input-port in-selection) #:prefab)
(struct mesg (in in-port msg) #:prefab)
(struct edge-in (name in in-port) #:prefab)
(struct edge-out (out out-port name) #:prefab)

(define-syntax (with-node-name stx)
  (match-define (cons _ (cons name exprs)) (syntax-e stx))

  (define (parse-expr expr)
    (syntax-case expr (edge edge-in)
      [(edge output-port input input-port) #`(edge #,name output-port #f input input-port #f)]
      [(edge output-port :selection output-sel input input-port)
       (eq? (string->keyword "selection") (syntax-e #':selection))
       #`(edge #,name output-port output-sel input input-port #f)]
      [(edge output-port input input-port :selection input-sel)
       (eq? (string->keyword "selection") (syntax-e #':selection))
       #`(edge #,name output-port #f input input-port input-sel)]
      [(edge output-port output-sel input input-port input-sel)
       #`(edge #,name output-port output-sel input input-port input-sel)]
      [(edge-in in-name port) #`(edge-in in-name #,name port)]
      [(cmd args ...) #`(cmd #,name args ...)]))

  #`(list #,@(map parse-expr exprs)))

(define make-graph
  (lambda actions
    (for/fold ([acc (graph '() '() '() '() '())])
              ([act (flatten actions)])
      (match act
        [g #:when (graph? g)
           g]
        [(g-agent name type)
         (struct-copy graph acc [agent (cons act (graph-agent acc))])]
        [(mesg in in-p msg)
         (struct-copy graph acc [mesg (cons (g-mesg in in-p msg) (graph-mesg acc))])]
        [(edge-in name input input-port)
         (struct-copy graph acc [virtual-in (cons (g-virtual "" name input input-port) (graph-virtual-in acc))])]
        [(edge-out output output-port name)
         (struct-copy graph acc [virtual-out (cons (g-virtual "" name output output-port) (graph-virtual-out acc))])]
        [(edge out out-p out-s in in-p in-s)
         (struct-copy graph acc [edge (cons (g-edge out out-p out-s in in-p in-s) (graph-edge acc))])]
        ))))

(define-syntax (define-graph stx)
  (syntax-case stx ()
    [(_ args ...)
     #'(begin
         (provide g)
         (define g (make-graph
                       args ...)))
     ]))

; TODO duplicate code in dynamic-add and dynamic-remove
(define (dynamic-remove delta input output)
  (define name (port-name (input "in")))
  ; rename to be unique
  ; agent
  (define new-agent (for/list ([agt (graph-agent delta)])
                      (struct-copy g-agent agt [name (string-append name "-" (g-agent-name agt))])))
  ; edge
  (define new-edge (for/list ([edg (graph-edge delta)])
                     (struct-copy g-edge edg [out (string-append name "-" (g-edge-out edg))]
                                  [in (string-append name "-" (g-edge-in edg))])))
  ; mesg
  (define new-mesg (for/list ([i (graph-mesg delta)])
                    (struct-copy g-mesg i [in (string-append name "-" (g-mesg-in i))])))
  ; virtual out - in
  (define new-v-in (for/list ([vi (graph-virtual-in delta)])
                     (struct-copy g-virtual vi [virtual-agent (string-append name "-" (g-virtual-virtual-agent vi))]
                                  [agent (string-append name "-" (g-virtual-agent vi))])))
  (define new-v-out (for/list ([vo (graph-virtual-out delta)])
                      (struct-copy g-virtual vo [virtual-agent (string-append name "-" (g-virtual-virtual-agent vo))]
                                   [agent (string-append name "-" (g-virtual-agent vo))])))
  (define new-delta (graph new-agent new-edge new-v-in new-v-out new-mesg))
  ; send the differences
  (agt:send (output "out") (cons 'dynamic-remove new-delta)))

  ; used to indicate that we don't care about out-selection and in-selection of an array port
  (define _ #f)
