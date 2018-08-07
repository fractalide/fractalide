#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "choice" ${gui.choice})
  (edge-out "choice" "out" "out")

  (node "choice-fan-in" ${plumbing.mux})
  (mesg "choice-fan-in" "option"
	(match-lambda [(cons _ data)
		       (list data)]))
  (edge "choice-fan-in" "out" _ "choice" "in" _)

  (node "choice-in" ${plumbing.identity})
  (edge-in "in" "choice-in" "in")
  (edge "choice-in" "out" _ "choice-fan-in" "in" "in")

  (node "choice-cmd" ${plumbing.mux})
  (edge "choice-cmd" "out" _ "choice-fan-in" "in" "cmd")

  (node "get-selection-cmd" ${plumbing.transform-in-msgs})
  (mesg "get-selection-cmd" "option"
        (match-lambda [(cons 'choice _)
                       (list (list* 'get-selection 'get-selection))]))
  (edge "choice" "out" 'choice "get-selection-cmd" "in" _)
  (edge "get-selection-cmd" "out" _ "choice-fan-in" "in" "get-selection-cmd")

  (node "select" ${plumbing.transform-in-msgs})
  (mesg "select" "option"
	(match-lambda [(cons 'get-selection selection)
		       (list selection)]))
  (edge "choice" "out" 'get-selection "select" "in" _)

  (node "model" ${cardano-wallet.wallets-model})
  (edge-in "add" "model" "add")
  (edge-in "delete" "model" "delete")
  (edge-in "init" "model" "in")
  (edge "select" "out" _ "model" "select" _)
  (edge "model" "select" _ "choice-cmd" "in" 'set-selection)
  (edge "model" "choices" _ "choice-cmd" "in" 'set-choices)
  (edge-out "model" "out" "choice"))
