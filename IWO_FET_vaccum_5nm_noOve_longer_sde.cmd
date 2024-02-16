
Device "IWO" {
File {
   * input files:
   Grid=   "@tdr@"
   Parameter= "@parameter@"


}

Electrode {
		{ Name="gate" Voltage=0 Workfunction=@WF@}
		{ Name="source" Voltage=0 Schottky Workfunction=@WFC@ eRecVelocity = 2.573e6 hRecVelocity = 1.93e6 DistResist= @Res@ } 
		{ Name="drain" Voltage=0 Schottky Workfunction=@WFC@ eRecVelocity = 2.573e6 hRecVelocity = 1.93e6 DistResist= @Res@ }
	}

Physics{
			eBarrierTunneling "NLMS" ( BarrierLowering )
			hBarrierTunneling "NLMS" ( BarrierLowering )

			eBarrierTunneling "NLMD" ( BarrierLowering  )
			hBarrierTunneling "NLMD" ( BarrierLowering  )
}

Physics 
{ 
    Temperature = 300
    AreaFactor = 1
    Fermi
}


Physics (Region="Semiconductor")
{
	Recombination (SRH)
	*eMultivalley(Nonparabolicity)
	Mobility(ConstantMobility)
}


} * End of Device{}

Plot
{
	eDensity hDensity
	eCurrent hCurrent
	eTemperature
	ElectricField
	eQuasiFermi hQuasiFermi eQuasiFermiEnergy hQuasiFermiEnergy
	Potential Doping SpaceCharge
	eMobility hMobility
	DonorConcentration 
	AcceptorConcentration
	eVelocity hVelocity
	conductionBandEnergy
	valenceBandEnergy
    eTrappedCharge hTrappedCharge  # contains also the interface chrages contribution
    eInterfaceTrappedCharge hInterfaceTrappedCharge
    BandGap
    EffectiveBandGap
    SRHRecombination  
    NonLocal

eBarrierTunneling
hBarrierTunneling
}



Math {
	Method=Blocked SubMethod=Super
	ACMethod=Blocked ACSubMethod=Super



	Extrapolate
	RelErrControl
	Digits= 5
	Iterations= 50
	Number_of_threads= 24
	ExitOnFailure
	Notdamped= 100
	Method= Blocked
	SubMethod= Super
	ACMethod= Blocked 
	ACSubMethod= Super
	DirectCurrent
	*ExtendedPrecision
	ErrRef(Electron)= 1e-8
	ErrRef(Hole)= 1e-8
    	RhsMin= 1e-20
	TrapDLN= 1000
	-checkUndefinedModels

Nonlocal "NLMS" ( *nonlocal tunneling mesh TLength from source
 Electrode="source" Length=10e-7
 Digits=4
)
 Nonlocal "NLMD" ( ##*nonlocal tunneling mesh TLength from drain
 Electrode="drain" Length=10e-7
 Digits=4
)
}

File {
	Output = "@log@"
	ACExtract = "@acplot@"
}



System {
  *-Physical devices:
  IWO nmos3 ( "source"=s  "drain"=d "gate"=g  )
  
  *-Lumped elements:
  Vsource_pset vs (s 0) { dc = 0.0 }
  Vsource_pset vg (g 0) { dc = 0.0 }   
  Vsource_pset vd (d 0) { dc = 0.0 }
}

Solve {
  
  NewCurrentPrefix="init_"
  Coupled(Iterations=100){ Poisson }
  Coupled{ Poisson Electron Hole  }
  
  Quasistationary ( 
    InitialStep=0.1 Increment=1.35
    MaxStep=0.5 Minstep=1e-7
    Goal { Parameter=vg.dc Voltage=@Vgs_min@}
    Goal { Parameter=vd.dc Voltage=@Vd@ }

  ){ Coupled { Poisson Electron Hole } }
  
  NewCurrentPrefix="CV_"
  Quasistationary (
    InitialStep=0.1 Increment=1.1
    MaxStep=0.3 Minstep=1e-8
    Goal { Parameter=vg.dc Voltage=@Vgs_max@ }
    Goal { Parameter=vd.dc Voltage=@Vd@ }

  ){ ACCoupled (
      StartFrequency=@freq@ EndFrequency=@freq@ NumberOfPoints=1 Decade
      Node(s d g ) Exclude(vg vd vs)
      ACMethod=Blocked 

      ACCompute (Time = (Range = (0 1)  Intervals = 26))

  ){ Poisson Electron Hole }
  }
}



;************2D Parametrized IWO FET SDE***************

(sde:clear)

(define n_type_dop   "PhosphorusActiveConcentration")

(define tox @tox@)
(define lch @lch@)
(define tch @tch@)
(define tbmetal @tbmetal@)
(define lbmov @lbmov@)
(define tSD @tSD@)
(define Lgap @Lgap@)
(define Lmax @<3*Lgap>@)
(define Nd @Nd@)

(define ltot (+ (* lbmov 2) (* tox 2) lch))   ; derived expression for ltot

(sdegeo:set-default-boolean "BAB")

;-------------------------------------------- Substrate --------------------------------------------

(sdegeo:create-rectangle 
 (position   0.000  (* -1 Lgap) 0.0) 
 (position   0.015  Lmax 0.0) "HfO2" "Substrate")


(sdegeo:create-rectangle 
 (position   0.000  (* -1 Lgap) 0.0) 
 (position   0.105  Lmax 0.0) "SiO2" "Substrate_below")

;-------------------------------------------- Bottom Metal --------------------------------------------


(sdegeo:create-polygon (list (position 0 (- 0 tbmetal) 0 ) (position (- 0 tbmetal) 0 0 ) (position (- 0 tbmetal) ltot 0 ) (position 0 (+ ltot tbmetal) 0 ) ) "Metal" "bottom_metal")

;-------------------------------------------- Bottom Oxide --------------------------------------------


(define A (sdegeo:create-polygon (list
(position   0  (- 0.000 tox tbmetal) 0.0) (position   (- 0 tbmetal tox)  (- 0.000 0) 0.0)  (position   (- 0 tbmetal tox) (+ ltot 0) 0.0) (position   0 (+ ltot tox tbmetal) 0.0)  ) "HfO2" "bottom_Oxide") )


(define B (sdegeo:create-rectangle
(position   0  @<-1*Lgap>@ 0.0) 
 (position   (- 0  tox)  Lmax 0.0) "HfO2" "bottom_Oxide1") )

(sdegeo:bool-unite (list A B))

;-------------------------------------------- IWO --------------------------------------------

(define A_IWO (sdegeo:create-polygon (list (position   0  (- 0.000 tox tbmetal tch)  0) (position   (- 0 tbmetal tox tch)  0  0) (position   (- 0 tbmetal tox tch)  ltot  0.0) (position   0  (+ ltot tbmetal tox tch)  0) ) "IWO" "Semiconductor") )

(define B_IWO (sdegeo:create-rectangle
(position   0  @<-1*Lgap>@ 0.0) 
 (position   (- 0  tox tch)  (+ ltot tox) 0.0) "IWO" "Semiconductor1") )


(sdepe:doping-constant-placement "Channel" n_type_dop (/ Nd 1) "Semiconductor")
(sdepe:doping-constant-placement "Channel1" n_type_dop (/ Nd 1) "Semiconductor1")

(sdegeo:bool-unite (list A_IWO B_IWO))

(define C_IWO (sdegeo:create-rectangle
(position   (- 0  tox ) ltot 0.0) 
 (position   (- 0  tox (* 1 tch) )  Lmax 0.0) "IWO" "HCSemiconductor") )

;(define D_IWO (sdegeo:create-rectangle (position   (- 0  tox ) (- ltot lbmov) 0.0)  (position   (- 0  tox tbmetal tch tch)  (+ ltot tox tch)  0.0) "IWO" "HCSemiconductor1") )

(define D_IWO (sdegeo:create-polygon (list (position  0 (- ltot lbmov) 0.0)  (position   (- 0  tox tbmetal tch tch) (- ltot lbmov) 0.0)  (position   (- 0  tox tbmetal tch tch)  ltot  0.0) (position   0  (+ ltot tbmetal tox tch tch)  0) ) "IWO" "HCSemiconductor1") )

(sdepe:doping-constant-placement "Channel2" n_type_dop (* Nd 2) "HCSemiconductor")
(sdepe:doping-constant-placement "Channel3" n_type_dop (* Nd 2) "HCSemiconductor1")

(sdegeo:bool-unite (list C_IWO D_IWO))

;-------------------------------------------- Source Metal --------------------------------------------

(sdegeo:create-rectangle 
(position 0 (- 0.0 tch tox tch tSD) 0.0)  
(position (- 0 tbmetal tox tch tSD ) lbmov  0) "Metal" "Source")

;-------------------------------------------- Drain Metal --------------------------------------------

(sdegeo:create-rectangle 
(position (+ (- 0  tox tch) offset) (+ ltot Lgap) 0.0)  
(position (+ (- 0  tox tch tSD) offset) (+ ltot Lgap lbmov)  0) "Metal" "Drain")

;-------------------------------------------- top Oxide --------------------------------------------

(sdegeo:create-rectangle 
(position 0  @<-1*Lgap>@ 0)  
(position (- 0 tbmetal tox tch (* 2 tSD)) Lmax  0) "Vacuum" "Toxide")


;------------------------------------------Set Contact------------------------------------------

(sdegeo:define-contact-set "source" 4  (color:rgb 1 0 0 ) "##")

(sdegeo:define-contact-set "gate" 4  (color:rgb 1 0 0 ) "##")

(sdegeo:define-contact-set "drain" 4  (color:rgb 1 0 0 ) "##") 

(sdegeo:set-contact (find-body-id (position (- 0 (/ tbmetal 2)) (+ lbmov tox (/ lch 2)) 0 ) ) "gate" "remove")


(sdegeo:set-contact (find-body-id (position (- 0 tbmetal tox tch (* tSD 0.8)) (/ lbmov 2) 0 ) ) "source" "remove")

(sdegeo:set-contact (find-body-id (position (- 0  tox tch (* tSD 0.8)) (+ ltot Lgap (/ lbmov 2)) 0 ) ) "drain" "remove" )

;------------------------------------------Constant Doping------------------------------------------



;*************************************************************************************************
;***************************************Meshing***************************************************
;*************************************************************************************************

(sdedr:define-refeval-window "MBWindow.Boxide" 
 "Rectangle"  
 (position (- 0 tbmetal) 0 0.0) 
 (position (- 0 tbmetal tox) (+ ltot Lgap) 0.0 ) )

(sdedr:define-multibox-size "MBSize.Boxide" 
  (/ tox 5) (/ ltot 60)
  (/ tox 6) (/ ltot 70)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Boxide" 
 "MBSize.Boxide"  "MBWindow.Boxide" )

(sdedr:define-refeval-window "MBWindow.Boxide1" 
 "Rectangle"  
 (position 0.0 (- 0 Lgap) 0.0) 
 (position (- 0 0 tox) Lmax 0.0) ) 

(sdedr:define-multibox-size "MBSize.Boxide1" 
  (/ tox 5) (/ ltot 20)
  (/ tox 6) (/ ltot 30)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Boxide1" 
 "MBSize.Boxide1"  "MBWindow.Boxide1" )


(sdedr:define-refeval-window "MBWindow.IWOS" 
 "Rectangle"  
 (position (- 0 tbmetal tox) 0 0.0) 
 (position (- 0 tbmetal tox tch) lbmov 0.0) ) 

(sdedr:define-multibox-size "MBSize.IWOS" 
  (/ tch 7) (/ tch 7)
  (/ tch 8) (/ tch 9) 
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.IWOS" 
 "MBSize.IWOS"  "MBWindow.IWOS" )

(sdedr:define-refeval-window "MBWindow.IWOD" 
 "Rectangle"  
 (position (- 0 tbmetal tox) ltot 0.0) 
 (position (- 0 tbmetal tox tch) (- ltot lbmov) 0.0) ) 

(sdedr:define-multibox-size "MBSize.IWOD" 
  (/ tch 7) (/ tch 7)
  (/ tch 8) (/ tch 9)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.IWOD" 
 "MBSize.IWOD"  "MBWindow.IWOD" )

(sdedr:define-refeval-window "MBWindow.Toxide" 
 "Polygon"  
(list 
 (position  (- 0 tbmetal tox tch tSD)  (- 0 Lgap)  0.0) 
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
 (position  (- 0 tbmetal tox tch tSD)  (+ ltot Lmax)  0.0)  ) )

(sdedr:define-multibox-size "MBSize.Toxide" 
  (/ tox 5)  (/ tox 7)
  (/ tox 6)  (/ tox 9)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Toxide" 
 "MBSize.Toxide"  "MBWindow.Toxide" )


(sdedr:define-refeval-window "MBWindow.Channel" 
 "Rectangle"  
 (position 0 lbmov 0.0) 
 (position (- 0 tbmetal tox tch tox) (+ ltot Lgap) 0.0) ) 

(sdedr:define-multibox-size "MBSize.Channel" 
  (/ tch 7) (/ lch 30)
  (/ tch 8) (/ lch 40)
  1.0         1.0)
(sdedr:define-multibox-placement "MBPlace.Channel" 
 "MBSize.Channel"  "MBWindow.Channel" )

(sde:build-mesh "snmesh" "-AI" "n@node@_msh")
