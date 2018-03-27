#lang racket/base

(require racket/class
         "toplevel.rkt")

(provide main)

(define (main)
  (define tl (new toplevel-window%))
  (send tl run))

(module+ main
  (require framework/splash)

  (set-splash-progress-bar?! #t)
  (start-splash "../../doc/images/fractalide.png" " " 0)
  (main)
  (shutdown-splash)
  (close-splash))
