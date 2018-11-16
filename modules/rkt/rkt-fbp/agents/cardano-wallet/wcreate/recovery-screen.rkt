#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "model" ${cardano-wallet.wcreate.model})

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 1)
  (mesg "headline" "in" '(init . ((label . "Wallet recovery

On the following screen, you will see a 14-word phrase. This is your wallet backup phrase.

Please make sure nobody looking at your screen unless you want them to have access to your funds."))))

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


  )
