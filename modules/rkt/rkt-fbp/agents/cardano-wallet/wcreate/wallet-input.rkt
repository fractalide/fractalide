#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-out "model" "next" "next")
  (edge-in "in" "vp" "in")

  (node "model" ${cardano-wallet.wcreate.wallet-input.model})

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 1)
  (mesg "headline" "in" '(init . ((label . "Create a wallet\n"))))

  (node "name" ${gui.text-field})
  (edge "name" "out" _ "vp" "place" 2)
  (mesg "name" "in" '(init . ((label . "Name : ")
                              (stretchable-width . #f))))
  (edge "name" "out" 'text-field "model" "name" _)

  (node "pwd" ${gui.text-field})
  (edge "pwd" "out" _ "vp" "place" 3)
  (mesg "pwd" "in" '(init . ((label . "Password : ")
                             (stretchable-width . #f))))
  (edge "pwd" "out" 'text-field "model" "pwd" _)

  (node "pwd-cfm" ${gui.text-field})
  (edge "pwd-cfm" "out" _ "vp" "place" 4)
  (mesg "pwd-cfm" "in" '(init . ((label . "Confirm : ")
                                 (stretchable-width . #f))))
  (edge "pwd-cfm" "out" 'text-field "model" "pwd-cfm" _)

  (node "error" ${gui.message})
  (edge "error" "out" _ "vp" "place" 9)
  (mesg "error" "in" '(init . ((label . ""))))
  (edge "model" "error" _ "error" "in" _)

  (node "hp" ${gui.horizontal-panel})
  (edge "hp" "out" _ "vp" "place" 10)
  (mesg "hp" "in" (cons 'set-stretchable-height #f))
  (mesg "hp" "in" (cons 'set-alignment (cons 'center 'center)))
  (node "back" ${gui.button})
  (edge "back" "out" _ "hp" "place" 1)
  (mesg "back" "in" '(init . ((label . "&Back"))))

  (node "next" ${gui.button})
  (edge "next" "out" _ "hp" "place" 2)
  (mesg "next" "in" '(init . ((label . "&Next"))))
  (edge "next" "out" 'button "model" "next" _)

  (node "cardano-create" ${cardano-cli.wallet.create})
  (edge "model" "name" _ "cardano-create" "name" _)
  (edge "model" "pwd" _ "cardano-create" "passwd" _)

  (edge-out "cardano-create" "out" "phrase")
  )
