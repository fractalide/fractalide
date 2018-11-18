#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-in "in" "vp" "in")
  (edge-out "vp" "out" "out")

  (node "model" ${cardano-wallet.wcreate.recovery-phrase.model})

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 1)
  (mesg "headline" "in" '(init . ((label . "Recovery phrase\n"))))

  (node "text" ${gui.message})
  (edge "text" "out" _ "vp" "place" 2)
  (mesg "text" "in" '(init . ((label . "The phrase is case sensitive. Please make sure your write down and save your recovery phrase. You will need this phrase to use and restore your wallet.\n"))))

  (node "phrase" ${gui.message})
  (edge "phrase" "out" _ "vp" "place" 3)
  (mesg "phrase" "in" '(init . ((label . ""))))

  (node "set-phrase" ${mesg.put-action})
  (mesg "set-phrase" "option" 'set-label)
  (edge-in "set-phrase" "set-phrase" "in")
  (edge "set-phrase" "out" _ "phrase" "in" _)

  (node "write" ${gui.check-box})
  (edge "write" "out" _ "vp" "place" 4)
  (mesg "write" "in" '(init . ((label . "Yes, I've written it down"))))
  (edge "write" "out" 'check-box "model" "1" _)

  (node "device" ${gui.check-box})
  (edge "device" "out" _ "vp" "place" 5)
  (mesg "device" "in" '(init . ((label . "I understand that my wallet and tokens are held securely on this device only and not on any servers."))))
  (edge "device" "out" 'check-box "model" "2" _)

  (node "last" ${gui.check-box})
  (edge "last" "out" _ "vp" "place" 5)
  (mesg "last" "in" '(init . ((label . "I understand that if this application is moved to another device or is deleted, my wallet can be only recovered with the backup phrase that I have written down and saved in a secure place."))))
  (edge "last" "out" 'check-box "model" "3" _)

  (node "error" ${gui.message})
  (edge "error" "out" _ "vp" "place" 6)
  (mesg "error" "in" '(init . ((label . ""))))
  (edge "model" "error" _ "error" "in" _)

  (node "hp" ${gui.horizontal-panel})
  (edge "hp" "out" _ "vp" "place" 10)
  (mesg "hp" "in" (cons 'set-stretchable-height #f))
  (mesg "hp" "in" (cons 'set-alignment (cons 'center 'center)))

  (node "back" ${gui.button})
  (edge "back" "out" _ "hp" "place" 1)
  (mesg "back" "in" '(init . ((label . "&Back"))))
  (node "set-back" ${mesg.set-mesg})
  (edge "back" "out" 'button "set-back" "in" _)
  (mesg "set-back" "option" (cons 'display #t))
  (edge-out "set-back" "out" "back")

  (node "next" ${gui.button})
  (edge "next" "out" _ "hp" "place" 2)
  (mesg "next" "in" '(init . ((label . "&Next"))))
  (edge "next" "out" 'button "model" "next" _)
  )
