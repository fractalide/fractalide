#lang racket

(require racket/draw)
(require racket/runtime-path)

(require fractalide/modules/rkt/rkt-fbp/graph)

(define-runtime-path address-qr-path "./baconipsum.png")
(define address-qr (read-bitmap address-qr-path))

(define-graph
  (node "vp" ${gui.vertical-panel})
  (edge-out "vp" "out" "out")
  (edge-in "in" "vp" "in")

  (node "headline" ${gui.message})
  (edge "headline" "out" _ "vp" "place" 10)
  (mesg "headline" "in" '(init . ((label . "Generated addresses"))))

  (node "hp" ${gui.horizontal-panel})
  (edge "hp" "out" _ "vp" "place" 20)

  (node "qr" ${gui.message})
  (edge "qr" "out" _ "hp" "place" 10)
  (mesg "qr" "in" `(init . ((label . ,address-qr))))

  (node "right" ${gui.vertical-panel})
  (edge "right" "out" _ "hp" "place" 20)

  (node "address" ${gui.message})
  (edge "address" "out" _ "right" "place" 10)
  (mesg "address" "in" '(init . ((label . "asdfjLKWJEFLKASDFqweLRKJasdfLQWKEJ"))))

  (node "generate-label" ${gui.message})
  (edge "generate-label" "out" _ "right" "place" 20)
  (mesg "generate-label" "in" '(init . ((label . "Generate new address"))))

  (node "down" ${gui.horizontal-panel})
  (edge "down" "out" _ "right" "place" 30)

  (node "password" ${gui.text-field})
  (edge "password" "out" _ "down" "place" 10)
  (mesg "password" "in" '(init . ((label . "Password")
                                  (style . (single password)))))

  (node "button" ${gui.button})
  (edge "button" "out" _ "down" "place" 20)
  (mesg "button" "in" '(init . ((label . "Generate")))))
