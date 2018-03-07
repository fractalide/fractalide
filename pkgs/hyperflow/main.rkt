#lang racket/base

(require racket/class
         "toplevel.rkt")

(provide main)

(define (main)
  (define tl (new toplevel-window%))
  (send tl run))

;(main)