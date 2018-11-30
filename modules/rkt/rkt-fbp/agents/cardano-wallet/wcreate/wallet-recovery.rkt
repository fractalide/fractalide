#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-in "in" "vp" "in")
  (edge-out "vp" "out" "out")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 1)
  (mesg "headline" "in" '(init . ((label . "Wallet recovery\n"))))

  (node "text" ${gui.message})
  (edge "text" "out" _ "vp" "place" 2)
  (mesg "text" "in" '(init . ((label . "On the following screen, you will see a 14-word phrase. This is your wallet backup phrase.
Please make sure nobody looking at your screen unless you want them to have access to your funds."))))

  (node "hp" ${gui.horizontal-panel})
  (edge "hp" "out" _ "vp" "place" 10)
  (mesg "hp" "in" (cons 'set-stretchable-height #f))
  (mesg "hp" "in" (cons 'set-alignment (cons 'center 'center)))

  (node "back" ${gui.button})
  (edge "back" "out" _ "hp" "place" 1)
  (mesg "back" "in" '(init . ((label . "&Back"))))

  (node "clone-back" ${clone})
  (edge "back" "out" 'button "clone-back" "in" _)

  (node "set-back" ${mesg.set-mesg})
  (edge "clone-back" "out" 1 "set-back" "in" _)
  (mesg "set-back" "option" (cons 'display #t))
  (edge-out "set-back" "out" "back")

  (node "next" ${gui.button})
  (edge "next" "out" _ "hp" "place" 2)
  (mesg "next" "in" '(init . ((label . "&Next"))))

  (node "set-display" ${mesg.set-mesg})
  (edge "next" "out" 'button "set-display" "in" _)
  (mesg "set-display" "option" (cons 'display #t))
  (edge-out "set-display" "out" "next")

  (node "destroy" ${cardano-cli.wallet.destroy})
  (node "trigger" ${mesg.set-mesg})
  (edge-in "destroy" "trigger" "option")
  (edge "trigger" "out" _ "destroy" "name" _)
  (edge "clone-back" "out" 2 "trigger" "in" _)

  )
