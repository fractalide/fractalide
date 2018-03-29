#lang racket/base

(require racket/class
         "toplevel.rkt")

(provide main)

(define (main)
  (define tl (new toplevel-window%))
  (send tl run))

(module+ main
  (require framework/splash)
  (require racket/runtime-path)

  (define-runtime-path splash-image "imgs/fractalide.png")

  (set-splash-progress-bar?! #t)
  (start-splash splash-image " " 0)
  (main)
  (shutdown-splash)
  (close-splash))
