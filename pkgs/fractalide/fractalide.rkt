#lang typed/racket

(provide build-fractal)

(require "fractal/fractal-maker.rkt")
(require "node/node-maker.rkt")
(require "subgraph/subgraph-maker.rkt")
(require "edge/edge-maker.rkt")

(define fractal-name "test")
(define language "rs")

(build-fractal fractal-name language)
(build-node fractal-name language "test_thunk")
(build-node fractal-name language "test_print")
(build-subgraph fractal-name language "test")
(build-edge fractal-name language "text_one")