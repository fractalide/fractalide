#lang info
(define collection "fractalide")
(define deps '("base" "gui-lib" "typed-map-lib" "typed-racket-more"))
(define build-deps '())
(define scribblings '())
(define pkg-desc "An IDE for Fractalide that enables building HyperCard-like applications. Fractalide is a free and open source service programming platform using dataflow graphs.")
(define version "0.0")
(define pkg-authors '("setori88@gmail.com" "claes.wallin@greatsinodevelopment.com"))
(define racket-launcher-names '("cardano-wallet"
                                "hyperflow"
                                "fracli"
                                "fvm"))
(define racket-launcher-libraries '("modules/rkt/rkt-fbp/agents/cardano-wallet.rkt"
                                    "modules/rkt/rkt-fbp/hyperflow.rkt"
                                    "pkgs/hyperflow/fracli.rkt"
                                    "modules/rkt/rkt-fbp/fvm.rkt"))
