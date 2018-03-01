#lang racket

(require framework/splash
         racket/lazy-require)

(set-splash-progress-bar?! #t)
(start-splash "../../doc/images/fractalide.png" " " 0)
(lazy-require ("default.rkt" (run)))
(run)
(shutdown-splash)
(close-splash)