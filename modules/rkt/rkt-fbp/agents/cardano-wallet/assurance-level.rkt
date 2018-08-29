#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "label" ${gui.message})
  (edge "label" "out" _ "vp" "place" 40)
  (mesg "label" "in" '(init . ((label . "Transaction assurance security level"))))

  (node "choice" ${gui.choice})
  (edge "choice" "out" _ "vp" "place" 50)
  (mesg "choice" "in" '(init . ((choices . ("Low" "Medium" "High")))))

  (node "in" ${plumbing.option-transform})
  (mesg "in" "option" (lambda (choice) (cons 'set-string-selection choice)))
  (edge "in" "out" _  "choice" "in" _)
  (edge-in "assurance-level" "in" "in")

  (node "out" ${plumbing.option-transform})
  (mesg "out" "option" (match-lambda [(cons 'choice choice) choice]))
  (edge "choice" "out" 'choice "out" "in" _)
  (edge-out "out" "out" "assurance-level"))
