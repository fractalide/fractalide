#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Wallet settings"))))

  (node "name" ${cardano-wallet.wsettings.name})
  (edge "name" "out" _ "vp" "place" 20)
  (edge-out "name" "name" "name")

  (node "name-fan-out" ${plumbing.demux})
  (mesg "name-fan-out" "option"
        (lambda (new-name) (list (list* "name" new-name))))
  (edge "name-fan-out" "out" "name" "name" "name" _)
  (edge-in "name" "name-fan-out" "in")

  (node "assurance-level" ${cardano-wallet.wsettings.assurance-level})
  (edge "assurance-level" "out" _ "vp" "place" 40)
  (edge-in "assurance-level" "assurance-level" "assurance-level")
  (edge-out "assurance-level" "assurance-level" "assurance-level")

  (node "password-label" ${gui.message})
  (edge "password-label" "out" _ "vp" "place" 60)
  (mesg "password-label" "in" '(init . ((label . "Password"))))

  (node "password" ${cardano-wallet.password})
  (edge "password" "out" _ "vp" "place" 70)

  (node "display-password" ${displayer})
  (mesg "display-password" "option" "set password: ")
  (edge "password" "password" _ "display-password" "in" _)

  (node "delete" ${cardano-wallet.wsettings.delete})
  (edge "delete" "out" _ "vp" "place" 80)
  (edge-in "in" "delete" "in")
  )
