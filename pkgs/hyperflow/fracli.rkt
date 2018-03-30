#lang racket/base

(require racket/cmdline
         "fractal-management/default.rkt")

(module+ main
  (command-line
   #:program "fracli"
   #:multi
   [("-n" "--node") fractal-name language node-name
                    "
   - fractal-name: 'example_name'; points to an existing fractal in your fractal directory
   - language: 'rs' or 'rkt'; 'rs' for Rust, 'rkt' for Racket
   - node-name: 'test_one'; use lowercase snake case"
                    (build-node fractal-name language node-name)]
   [("-s" "--subgraph") fractal-name language subgraph-name
                                        "
   - fractal-name: 'example_name'; points to an existing fractal in your fractal directory
   - language: 'rs' or 'rkt'; 'rs' for Rust, 'rkt' for Racket
   - subgraph-name: 'test_one'; use lowercase snake case"
                    (build-subgraph fractal-name language subgraph-name)]
   [("-e" "--edge") fractal-name language edge-name
                                        "
   - fractal-name: 'example_name'; points to an existing fractal in your fractal directory
   - language: 'rs' or 'rkt'; 'rs' for Rust, 'rkt' for Racket
   - edge-name: 'test_one'; use lowercase snake case"
                    (build-edge fractal-name language edge-name)]
   [("-f" "--fractal") fractal-name language
                                        "
   - fractal-name: 'example_name'; directory will be created in fractal directory
   - language: 'rs' or 'rkt'; 'rs' for Rust, 'rkt' for Racket"
                    (build-fractal fractal-name language)]))
