#lang racket/base

(require racket/gui)

(provide gui)

(require "menu/default.rkt")
(require "body/default.rkt")

(define (gui parent)
  (menu parent)
  (body parent)
  parent)
