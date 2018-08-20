#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Wallet settings"))))

  (node "name-label" ${gui.message})
  (edge "name-label" "out" _ "vp" "place" 20)
  (mesg "name-label" "in" '(init . ((label . "Name"))))

  (node "name" ${gui.text-field})
  (edge "name" "out" _ "vp" "place" 30)
  (mesg "name" "in" '(init . ((label . ""))))

  (node "name-in" ${plumbing.option-transform})
  (mesg "name-in" "option" (lambda (x) (cons 'set-value x)))
  (edge "name-in" "out" _ "name" "in" _)
  (edge-in "name" "name-in" "in")

  (node "name-out" ${plumbing.option-transform})
  (mesg "name-out" "option" cdr)
  (edge "name" "out" 'text-field-enter "name-out" "in" _)
  (edge-out "name-out" "out" "name")

  (node "assurance-level-label" ${gui.message})
  (edge "assurance-level-label" "out" _ "vp" "place" 40)
  (mesg "assurance-level-label" "in" '(init . ((label . "Transaction assurance security level"))))

  (node "assurance-level" ${gui.choice})
  (edge "assurance-level" "out" _ "vp" "place" 50)
  (mesg "assurance-level" "in" '(init . ((choices . ("Low" "Medium" "High")))))

  (node "assurance-level-in" ${plumbing.option-transform})
  (mesg "assurance-level-in" "option" (lambda (choice) (cons 'set-string-selection choice)))
  (edge "assurance-level-in" "out" _  "assurance-level" "in" _)
  (edge-in "assurance-level" "assurance-level-in" "in")

  (node "assurance-level-out" ${plumbing.option-transform})
  (mesg "assurance-level-out" "option" (match-lambda [(cons 'choice choice) choice]))
  (edge "assurance-level" "out" 'choice "assurance-level-out" "in" _)
  (edge-out "assurance-level-out" "out" "assurance-level")

  (node "password-label" ${gui.message})
  (edge "password-label" "out" _ "vp" "place" 60)
  (mesg "password-label" "in" '(init . ((label . "Password"))))

  (node "password" ${cardano-wallet.password})
  (edge "password" "out" _ "vp" "place" 70)
  (mesg "password" "in" '(display . #t))

  (node "display-password" ${displayer})
  (mesg "display-password" "option" "set password: ")
  (edge "password" "password" _ "display-password" "in" _)

  (node "delete" ${cardano-wallet.delete})
  (edge "delete" "out" _ "vp" "place" 80)
  (mesg "delete" "in" '(display . #t))
  (edge-out "delete" "delete" "delete")
  (mesg "delete" "wallet-name" "my wallet"))
