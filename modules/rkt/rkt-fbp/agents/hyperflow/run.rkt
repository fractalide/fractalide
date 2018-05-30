#lang racket

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-graph
  (node "frame" ${gui.frame})
  (node "vp" ${gui.vertical-panel})
  (edge "vp" "out" _ "frame" "in" _)
  ; path selection
  (node "hp-selec" ${gui.horizontal-panel})
  (edge "hp-selec" "out" _ "vp" "place" 1)
  (mesg "hp-selec" "in" '(set-stretchable-height . #f))
  (node "selec" ${gui.text-field})
  (node "selec-but" ${gui.button})
  (edge "selec" "out" _ "hp-selec" "place" 1)
  (edge "selec-but" "out" _ "hp-selec" "place" 2)
  (mesg "selec" "in" '(init . ((label . "Node path:"))))
  (mesg "selec-but" "in" '(init . ((label . "go"))))
  (mesg "selec-but" "option" '(get-value . update-type))
  (edge "selec-but" "out" 'get-value "selec" "in" _)
  (edge "selec" "out" 'update-type "node" "in" _)
  ; node
  (node "node" ${hyperflow.node})
  (edge "node" "out" _ "vp" "place" 2)
  (mesg "node" "in" '(init . ""))
  )
