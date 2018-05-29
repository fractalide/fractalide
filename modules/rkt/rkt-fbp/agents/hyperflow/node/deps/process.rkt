#lang racket

(provide agt)

(require fractalide/modules/rkt/rkt-fbp/agent)

(define agt
  (define-agent
    #:input '("in")
    #:output '("out")
    #:proc
    (lambda (input output input-array output-array)
      (define msg (recv (input "in")))
      (define acc (or (try-recv (input "acc")) #f))
      (match msg
        [(cons 'init opt)
         ;retrieve the on-delete
         (define on-delete (findf (lambda (el) (eq? (car el) 'on-delete)) opt))
         (set! acc (cdr on-delete))
         (define new-opt (remove 'on-delete opt (lambda (x y) (eq? x (car y)))))
         (send (output "out") (cons 'init new-opt))]
        [(cons 'delete #t)
         (send (output "out") (cons 'get-plain-label acc))]
        [else (send (output "out") msg)]
        )
      (send (output "acc") acc))))
