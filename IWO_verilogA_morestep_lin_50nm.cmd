
;************2D Parametrized IWO FET SDE***************

(sde:clear)

(define n_type_dop   "PhosphorusActiveConcentration")

(define tox @tox@)
(define lch @lch@)
(define tch @tch@)
(define tbmetal 0.010)
(define lbmov @lbmov@)
(define tSD @tSD@)
(define Nd @Nd@)

(define ltot (+ (* lbmov 2) (* tox 2) lch))   ; derived expression for ltot

(sdegeo:set-default-boolean "BAB")

;-------------------------------------------- Bottom Metal --------------------------------------------

(sdegeo:create-rectangle 
 (position   0.000  0.000 0.0) 
 (position   (- 0 tbmetal)  ltot 0.0) "Metal" "bottom_metal")

;-------------------------------------------- Bottom Oxide --------------------------------------------

(sdegeo:create-rectangle
(position   (- 0 tbmetal)  0.000 0.0) 
 (position   (- 0 tbmetal tox)  ltot 0.0) "HfO2" "bottom_Oxide")

;-------------------------------------------- IWO --------------------------------------------

(sdegeo:create-rectangle
(position   (- 0 tbmetal tox)  0.000 0.0) 
(position   (- 0 tbmetal tox tch)  ltot 0.0) "IWO" "Semiconductor")

;-------------------------------------------- Source Metal --------------------------------------------

(sdegeo:create-rectangle 
(position (- 0 tbmetal tox tch) 0.000 0.0)  
(position (- 0 tbmetal tox tch tSD) lbmov  0) "Metal" "Source")

;-------------------------------------------- Drain Metal --------------------------------------------

(sdegeo:create-rectangle 
(position (- 0 tbmetal tox tch) (- ltot lbmov) 0.0)  
(position (- 0 tbmetal tox tch tSD) (+ ltot) 0) "Metal" "Drain")

;-------------------------------------------- top Oxide --------------------------------------------

(sdegeo:create-polygon (list 
 (position  (- 0 tbmetal tox tch tSD)  0.000  0.0) 
 (position  (- 0 tbmetal tox tch tSD)  lbmov  0.0) 
 (position  (- 0 tbmetal tox tch)  lbmov 0.0) 
 (position  (- 0 tbmetal tox tch) (- ltot lbmov) 0.0) 
 (position  (- 0 tbmetal tox tch tSD) (- ltot lbmov) 0.0) 
 (position  (- 0 tbmetal tox tch tSD) ltot 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) ltot 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) (- ltot (+ lbmov tox)) 0.0) 
 (position  (- 0 tbmetal tox tch tox) (- ltot (+ lbmov tox)) 0.0) 
 (position  (- 0 tbmetal tox tch tox) (+ lbmov tox) 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) (+ lbmov tox) 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) 0.00 0.0) 
 (position  (- 0 tbmetal tox tch tSD)  0.000  0.0) ) "HfO2" "top_Oxide")

;-------------------------------------------- top Metal --------------------------------------------

(sdegeo:create-rectangle 
(position (- 0 tbmetal tox tch tox) lbmov 0.000)  
(position (- 0 tbmetal tox tch tSD tox 0.005) (- ltot lbmov)  0) "Metal" "top_metal")

;------------------------------------------Set Contact------------------------------------------

(sdegeo:define-contact-set "source" 4  (color:rgb 1 0 0 ) "##")

(sdegeo:define-contact-set "gate" 4  (color:rgb 1 0 0 ) "##")

(sdegeo:define-contact-set "drain" 4  (color:rgb 1 0 0 ) "##") 

(sdegeo:set-contact (find-body-id (position (- 0 (/ tbmetal 2)) (+ lbmov tox (/ lch 2)) 0 ) ) "gate" "remove")

(sdegeo:set-contact (find-body-id (position (- 0 tbmetal tox tch tox 0.0025)  (+ lbmov tox (/ lch 2)) 0 ) ) "gate" "remove")

(sdegeo:set-contact (find-body-id (position (- 0 tbmetal tox tch (/ tSD 2)) 0 0 ) ) "source" "remove")

(sdegeo:set-contact (find-body-id (position (- 0 tbmetal tox tch (/ tSD 2)) ltot 0 ) ) "drain" "remove")

;------------------------------------------Constant Doping------------------------------------------

(sdepe:doping-constant-placement "Channel" n_type_dop Nd "Semiconductor")


;*************************************************************************************************
;***************************************Meshing***************************************************
;*************************************************************************************************

(sdedr:define-refeval-window "MBWindow.Boxide" 
 "Rectangle"  
 (position (- 0 tbmetal) 0 0.0) 
 (position (- 0 tbmetal tox) ltot 0.0) ) 

(sdedr:define-multibox-size "MBSize.Boxide" 
  (/ tox 6) (/ ltot 50)
  (/ tox 8) (/ ltot 60)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Boxide" 
 "MBSize.Boxide"  "MBWindow.Boxide" )

(sdedr:define-refeval-window "MBWindow.IWOS" 
 "Rectangle"  
 (position (- 0 tbmetal tox) 0 0.0) 
 (position (- 0 tbmetal tox tch) lbmov 0.0) ) 

(sdedr:define-multibox-size "MBSize.IWOS" 
  (/ tch 7) (/ lbmov 35)
  (/ tch 8) (/ lbmov 45)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.IWOS" 
 "MBSize.IWOS"  "MBWindow.IWOS" )

(sdedr:define-refeval-window "MBWindow.IWOD" 
 "Rectangle"  
 (position (- 0 tbmetal tox) ltot 0.0) 
 (position (- 0 tbmetal tox tch) (- ltot lbmov) 0.0) ) 

(sdedr:define-multibox-placement "MBPlace.IWOD" 
 "MBSize.IWOS"  "MBWindow.IWOD" )

(sdedr:define-refeval-window "MBWindow.Toxide" 
 "Polygon"  
(list 
 (position  (- 0 tbmetal tox tch tSD)  0.000  0.0) 
 (position  (- 0 tbmetal tox tch tSD)  lbmov  0.0) 
 (position  (- 0 tbmetal tox tch)  lbmov 0.0) 
 (position  (- 0 tbmetal tox tch) (- ltot lbmov) 0.0) 
 (position  (- 0 tbmetal tox tch tSD) (- ltot lbmov) 0.0) 
 (position  (- 0 tbmetal tox tch tSD) ltot 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) ltot 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) (- ltot (+ lbmov tox)) 0.0) 
 (position  (- 0 tbmetal tox tch tox) (- ltot (+ lbmov tox)) 0.0) 
 (position  (- 0 tbmetal tox tch tox) (+ lbmov tox) 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) (+ lbmov tox) 0.0) 
 (position  (- 0 tbmetal tox tch tSD tox) 0.00 0.0) 
 (position  (- 0 tbmetal tox tch tSD)  0.000  0.0)  ) )

(sdedr:define-multibox-size "MBSize.Toxide" 
  (/ tox 7) (/ lbmov 35)
  (/ tox 9) (/ lbmov 45)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Toxide" 
 "MBSize.Toxide"  "MBWindow.Toxide" )

(sdedr:define-refeval-window "MBWindow.Channel" 
 "Rectangle"  
 (position (- 0 tbmetal) lbmov 0.0) 
 (position (- 0 tbmetal tox tch tox) (- ltot lbmov) 0.0) ) 

(sdedr:define-multibox-size "MBSize.Channel" 
  (/ tch 7) (/ lch 50)
  (/ tch 9) (/ lch 60)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Channel" 
 "MBSize.Channel"  "MBWindow.Channel" )

(sde:build-mesh "snmesh" "-AI" "n@node@_msh")
