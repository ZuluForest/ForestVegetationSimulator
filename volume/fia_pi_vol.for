! This is from NIMS_VOl_PACIFIC_ISLANDS package
! Created by YW 2018/08/28
! ---------------------------------------------------------------------
!--Cubic foot volume of main stem outside bark to a variable top and stump
!--Developed by Olaf Kuegler for Pacific Island inventory
!-- UPDIA = Centroid Diameter
!-- UPHT = Centroid Height
! CU000150 FUNCTION CENTROID_CV
! NVEL EQUATION NUMBER:
! P03CEN0000
      SUBROUTINE CENTROID_CV(DIA,THT,UPDIA,UPHT,MTOPP,STUMP,VOL,ERRFLG)
      REAL DIA,THT,UPD,UPHT,MTOPP,TOPD,STUMP,VOL(15),A,HT_STUMP
      INTEGER ERRFLG
      CV(THT,UPDIA,UPHT,TOPD,STUMP,A) = 
     &  3.14/4.0 *(UPDIA**2)*(A/(A+2.0))*((THT-UPHT)**(-2.0/A))*
     &     ((THT-STUMP)**((A+2.0)/A) -(THT-UPHT)**((A+2.0)/A)*
     &     (TOPD/UPDIA)**(A+2.0))/144.0
      A = 2.0
      IF(MTOPP.LT.0.1) MTOPP = 4.0
      IF(STUMP.LT.0.1) STUMP = 1.0
      VOL = 0.0
      TOPD = 0.0
      HT_STUMP = 0.0
      IF(UPDIA.LT.0.1.OR.UPHT.LT.0.1)THEN
        ERRFLG = 9
        RETURN
      ENDIF
      VOL(1) = CV(THT,UPDIA,UPHT,TOPD,HT_STUMP,A)
      TOPD = MTOPP
      HT_STUMP = STUMP
      VOL(4) = CV(THT,UPDIA,UPHT,TOPD,HT_STUMP,A)
      IF(VOL(1).LT.0.0) VOL(1) = 0.1
      IF(VOL(4).LT.0.0) VOL(4) = 0.1
      RETURN
      END SUBROUTINE CENTROID_CV
! ---------------------------------------------------------------------
!--Cubic foot volume of main stem outside bark from stump to tip
!-- DIA_UPPER = Upper Stem Diameter
!-- HT_UPPER  = Height to Upper Stem dia measurement
! CU000146 FRUSTRUM_CVTS(DBH, THT, DIA_UPPER, HT_UPPER, HT_DBH)
! CU000147 FRUSTRUM_CVTS_PHY(DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, HT_DBH)
! CU000148 FRUSTRUM_CV4(DBH, THT, DIA_UPPER, HT_UPPER, HT_DBH)
! CU000149 FRUSTRUM_CV4_PHY(DBH, THT, DIA_UPPER, HT_UPPER, HT_DBH)
! NVEL EQUATION NUMBER:
! P03FRU0000
      SUBROUTINE FRUSTRUM_VOL(DBHOB,DRCOB,HTTOT,UPSHT1,UPSD1,
     & UPSHT2,UPSD2,MTOPP,STUMP,VOL,ERRFLG)
! UPSHT1 - HT_UPPER = Height to Upper Stem dia measurement
! UPSD1 - DIA_UPPER = Upper Stem Diameter
! UPSHT2 - HT_BREAK = Height to top break 
! UPSD2 = Set to 0 when UPSHT2 is height to top break
      REAL DBHOB,DRCOB,HTTOT,UPSHT1,UPSD1,UPSHT2,UPSD2,VOL(15)
      INTEGER ERRFLG
      REAL DBH,THT,HTDBH,UPDIA,UPHT,HT2BRK,MTOPP,TOPD,STUMP
      REAL CVTS,CV4,DRC,TAPER_ANGEL,VOL_LOWER,VOL_MID,VOL_UPPER
      REAL STUMPD,HTTOP,DIA_BREAK,TAPER_ANGEL2
      REAL DIA_TOP_BREAK,HT_TOP_BREAK,STUMPV,D1,D2,LEN,PI
      FRUSTRUMV(LEN,D1,D2) = PI*LEN/3.0*(D1**2+D1*D2+D2**2)/24.0**2
      ERRFLG = 0
      VOL = 0.0
      PI = 3.1415927
      TAPER_ANGEL2 = 0.0
      IF(DBHOB.GT.0.1)THEN
        DBH = DBHOB
        HTDBH = 4.5
      ELSEIF(DRCOB.GT.0.1)THEN
        DBH = DRCOB
        HTDBH = 0.0
      ENDIF
      THT = HTTOT
      IF(STUMP.LT.0.1) STUMP = 1.0
      TOPD = MTOPP
      IF(TOPD.LT.0.1) TOPD = 4.0
      UPHT = UPSHT1
      UPDIA = UPSD1
      IF(UPHT.LE.HTDBH)THEN
        ERRFLG = 7
        RETURN
      ENDIF
      TAPER_ANGLE = ATAN(((DBH-UPDIA)/24.0)/(UPHT-HTDBH))  
      DRC = DBH + 24.0*HTDBH*TAN(TAPER_ANGLE) 
      STUMPD = DBH + 24.0*(HTDBH-1.0)*TAN(TAPER_ANGLE)   
      
      LEN = HTDBH
      VOL_LOWER = FRUSTRUMV(LEN,DRC,DBH)
      LEN = UPHT-HTDBH
      VOL_MID = FRUSTRUMV(LEN,DBH,UPDIA)
      LEN = THT - UPHT
      VOL_UPPER = FRUSTRUMV(LEN,UPDIA,0.0)
      CVTS = VOL_LOWER+VOL_MID+VOL_UPPER
!     CALC CV4
      IF(UPDIA.LE.TOPD) THEN
        LEN = UPHT-1.0
        VOL_LOWER = FRUSTRUMV(LEN,STUMPD,UPDIA)
        VOL_UPPER = 0.0
      ELSEIF(UPHT.EQ.THT) THEN
        LEN = UPHT-1.0
        VOL_LOWER = FRUSTRUMV(LEN,STUMPD,UPDIA)
        VOL_UPPER = 0.0
      ELSEIF(UPDIA.GT.TOPD) THEN
        TAPER_ANGLE2 = ATAN((UPDIA/24.0)/(THT-UPHT))
        HTTOP = THT - (TOPD/24.0)/TAN(TAPER_ANGLE2)
        LEN = UPHT-1.0
        VOL_LOWER = FRUSTRUMV(LEN,STUMPD,UPDIA)
        LEN = HTTOP-UPHT
        VOL_UPPER = FRUSTRUMV(LEN,UPDIA,TOPD)
      ELSE
        VOL_LOWER = 0.0
        VOL_UPPER = 0.0
      ENDIF
      CV4 = VOL_LOWER+VOL_UPPER
!--Cubic foot volume of main stem outside bark from ground to tip excluing broken top.
      IF(UPSHT2.GT.4.5.AND.UPSD2.EQ.0.0)THEN
        HT2BRK = UPSHT2
        IF(UPHT.GE.HT2BRK) THEN  !-- Upper measurement at break
          LEN = UPHT
          VOL_LOWER = FRUSTRUMV(LEN,DRC,UPDIA)
          VOL_UPPER = 0.0
        ELSEIF(UPHT.EQ.THT) THEN         !-- Handel error when upper measurement same as height
          LEN = UPHT
          VOL_LOWER = FRUSTRUMV(LEN,DRC,UPDIA)
          VOL_UPPER = 0.0
        ELSEIF(UPHT.LT.HT2BRK) THEN !-- Upper measurement below break
          TAPER_ANGLE2 = ATAN((UPDIA/24.0)/(THT-UPHT))
          DIA_BREAK = UPDIA - 24.0*(HT2BRK-UPHT)*TAN(TAPER_ANGLE2)
          LEN = UPHT
          VOL_LOWER = FRUSTRUMV(LEN,DRC,UPDIA)
          LEN = HT2BRK-UPHT
          VOL_UPPER = FRUSTRUMV(LEN,UPDIA,DIA_BREAK)
        ELSE
          VOL_LOWER = 0.0
          VOL_UPPER = 0.0
        ENDIF
        CVTS = VOL_LOWER+VOL_UPPER
!       CALC CV4
        IF(THT.GT.UPHT)THEN
          TAPER_ANGEL2 = ATAN((UPDIA/24.0)/(THT-UPHT))     
        ELSE
          TAPER_ANGEL2 = TAPER_ANGEL
        ENDIF
!      --Find Diameter at break
        IF(UPHT.LT.HT2BRK) THEN !-- Upper measurement below break
          DIA_BREAK = UPDIA - 24.0*(HT2BRK-UPHT)*TAN(TAPER_ANGLE2)
        ELSE
          DIA_BREAK = DBH - 24.0*(UPHT-HTDBH)*TAN(TAPER_ANGLE2)
        ENDIF
!      --Find DIA and HT to lowest of break or merch top
        IF((TOPD.LE.DIA_BREAK) .OR. (THT.LE.UPHT)) THEN
          DIA_TOP_BREAK = DIA_BREAK
          HT_TOP_BREAK = HT2BRK
        ELSE
          DIA_TOP_BREAK = DIA_TOP
          IF(TAPER_ANGLE2 .EQ. 0.0) THEN
            RETURN
          ENDIF
          HT_TOP = THT - (TOPD/24.0)/TAN(TAPER_ANGLE2);
          HT_TOP_BREAK = HT_TOP
        ENDIF
        IF(UPDIA.LE.DIA_TOP_BREAK) THEN
          LEN = UPHT-1.0
          VOL_LOWER = FRUSTRUMV(LEN,STUMPD,UPDIA)
          VOL_UPPER = 0.0
        ELSEIF(UPHT.EQ.THT) THEN
          LEN = UPHT-1.0
          VOL_LOWER = FRUSTRUMV(LEN,STUMPD,UPDIA)
          VOL_UPPER = 0.0
        ELSEIF(UPDIA.GT.DIA_TOP_BREAK) THEN
          LEN = UPHT-1.0
          VOL_LOWER = FRUSTRUMV(LEN,STUMPD,UPDIA)
          LEN = HT_TOP_BREAK-UPHT
          VOL_UPPER = FRUSTRUMV(LEN,UPDIA,DIA_TOP_BREAK)
        ELSE
          VOL_LOWER = 0.0
          VOL_UPPER = 0.0
        ENDIF
        CV4 = VOL_LOWER+VOL_UPPER
      ENDIF
      STUMPV = 0.002727*(DRC**2+STUMPD**2)
      VOL(14) = STUMPV
      VOL(1) = CVTS - STUMPV
      VOL(4) = CV4
      RETURN
      END SUBROUTINE FRUSTRUM_VOL
!-------------------------------------------------------------------------------
!--Function used to compute volume of tree ferns in Pacific Islands 2001 compilation
!--Assumes cone from ground to tip
!--Above ground stem volume outside bark.
      SUBROUTINE CONE_VOL(DBHOB,DRCOB,HTTOT,UPSHT2,UPSD2,MTOPP,
     & STUMP,VOL,ERRFLG)
      REAL DBHOB,DRCOB,HTTOT,UPSHT2,UPSD2,MTOPP,VOL(15),STUMP
      INTEGER ERRFLG
      REAL DBH,HT,HT_DBH,DRC,CVTS,TAPER_ANGLE,DIA_STUMP,HT_TOP
      REAL HT_BREAK,HT_STUMP,DIA_TOP,STUMPV,PI,LEN,D1,D2
      FRUSTRUMV(LEN,D1,D2) = PI*LEN/3.0*(D1**2+D1*D2+D2**2)/24.0**2
      PI = 3.1415927
      IF(DBHOB.GT.0.1)THEN
        DBH = DBHOB
        HT_DBH = 4.5
      ELSEIF(DRCOB.GT.0.1)THEN
        DBH = DRCOB
        HT_DBH = 0.0
      ENDIF
      ERRFLG = 0
      VOL = 0.0
      CVTS = 0.0
      CV4 = 0.0
      HT = HTTOT
      IF(STUMP.LT.0.1)THEN STUMP = 1.0
      HT_STUMP = STUMP
      IF(MTOPP.LT.0.1)THEN MTOPP = 4.0
!      DIA_TOP = MTOPP
      DIA_TOP = 4.0
      IF(HT.LE.HT_DBH)THEN
        ERRFLG = 4
        RETURN
      ENDIF
      TAPER_ANGLE = ATAN((DBH/24.0)/(HT-HT_DBH))
      DRC = 24.0*HT*TAN(TAPER_ANGLE)
      CVTS = 3.14/3.0 * (DRC/24.0)**2 * HT
      DIA_STUMP = DBH + 24.0*(HT_DBH-1.0)*TAN(TAPER_ANGLE)
      HT_TOP = HT - (DIA_TOP/24.0)/TAN(TAPER_ANGLE)
      LEN = HT_TOP-1.0
      CV4 = FRUSTRUMV(LEN,DIA_STUMP,DIA_TOP)
      IF(UPSHT2.GT.4.5.AND.UPSD2.EQ.0.0)THEN
        HT_BREAK = UPSHT2
        DRC = DBH + 24.0*HT_DBH*TAN(TAPER_ANGLE)
        DIA_BREAK = DBH - 24.0*(HT_BREAK-HT_DBH)*TAN(TAPER_ANGLE)
        IF(HT.GE.HT_BREAK) THEN
          CVTS = 3.14/3.0 * (DRC/24.0)**2 * HT
        ELSE
          CVTS = FRUSTRUMV(HT_BREAK,DRC,DIA_BREAK)
        END IF;
        DIA_STUMP = 24.0*(HT-HT_STUMP)*TAN(TAPER_ANGLE)
        DIA_BREAK = 24.0*(HT-HT_BREAK)*TAN(TAPER_ANGLE)
        HT_TOP = HT - (DIA_TOP/24.0)/TAN(TAPER_ANGLE)
        IF(HT_TOP.LT.HT_BREAK) THEN
          LEN = HT_TOP-HT_STUMP
          CV4 = FRUSTRUMV(LEN,DIA_STUMP,DIA_TOP)
        ELSE
          LEN = HT_BREAK-HT_STUMP
          CV4 = FRUSTRUMV(LEN,DIA_STUMP,DIA_BREAK)
        ENDIF
      ENDIF
      STUMPV = 0.002727*(DRC**2+DIA_STUMP**2)
      VOL(14) = STUMPV
      VOL(1) = CVTS - STUMPV
      VOL(4) = CV4
      RETURN
      END SUBROUTINE CONE_VOL
!-------------------------------------------------------------------------------
!--Picks Pacific Island volume equations based on what tree measurements
!--were taken and species.
! CU000140 PACIFIC_ISLAND_CVTS_OB(VOLSPN, DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, DIA_CENTROID, HT_CENTROID, HT_DBH)
! CU000141 PACIFIC_ISLAND_CVTS_PHY_OB(VOLSPN, DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, DIA_CENTROID, HT_CENTROID, HT_DBH)
! CU000142 PACIFIC_ISLAND_CVTS_NET_OB(VOLSPN, DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, DIA_CENTROID, HT_CENTROID, HT_DBH)
! CU000143 PACIFIC_ISLAND_CV4_OB(VOLSPN, DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, DIA_CENTROID, HT_CENTROID, HT_DBH)
! CU000144 PACIFIC_ISLAND_CV4_PHY_OB(VOLSPN, DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, DIA_CENTROID, HT_CENTROID, HT_DBH)
! CU000145 PACIFIC_ISLAND_CV4_NET_OB(VOLSPN, DBH, THT, HT_BREAK, DIA_UPPER, HT_UPPER, DIA_CENTROID, HT_CENTROID, HT_DBH)
! NVEL VOLUME EQUATION NUMBER:
! P03ISL****
      SUBROUTINE PACIFIC_ISLAND(VOLEQ,DBHOB,DRCOB,HTTOT,UPSHT1,UPSD1,
     & UPSHT2,UPSD2,MTOPP,STUMP,VOL,ERRFLG)
! UPSHT1 - HT_UPPER = Height to Upper Stem dia measurement
! UPSD1 - DIA_UPPER = Upper Stem Diameter
! UPSHT2 - HT_BREAK = Height to top break 
! UPSD2 - When UPSHT2 is height to top break, UPSD2 has to be 0 and THT needs to be 0
! OR
! CU000150 FUNCTION CENTROID_CV
! UPSHT2 - HT_CENTROID = The height (in feet) to stem centroid 
! UPSD2 - DIA_CENTROID = Centroid diameter
      CHARACTER*10 VOLEQ
      REAL DBHOB,DRCOB,HTTOT,UPSHT1,UPSD1,UPSHT2,UPSD2,MTOPP,STUMP
      REAL VOL(15)
      INTEGER ERRFLG,SPN
      REAL DIA,HT,HT_BREAK,DIA_UPPER,HT_UPPER,DIA_CENTROID,HT_CENTROID
      REAL HT_DBH,DIA_TOP,HT_STUMP,CVTS,CV4
      CYLINDER_CVTS(DIA,HT) = 3.14 * (DIA/24.0)**2 * HT
      IF(MTOPP.LT.0.1) MTOPP = 4.0
      IF(STUMP.LT.0.1) STUMP = 1.0
      READ(VOLEQ(7:10),'(I4)')SPN
      IF(DBHOB.GT.0.1)THEN
        DIA = DBHOB
      ELSEIF(DRCOB.GT.0.1)THEN
        DIA = DRCOB
      ENDIF
      VOL = 0.0
      HT = HTTOT
      IF(SPN.GE.6545.AND.SPN.LE.6549)THEN !SPN IN (6545, 6546, 6547, 6548, 6549)
C       IF TREES HAVE BROKEN HEIGHT AND NO TOTAL HEIGHT
C       THE BROKEN HEIGHT IS INPUTED AS UPSHT2 AND UPSD2 IS SET 0      
        IF(UPSHT2.GT.0.1.AND.UPSD2.EQ.0.0) HT = UPSHT2
        VOL(1) = CYLINDER_CVTS(DIA,HT)
        VOL(4) = VOL(1)
C     TREES WITH UPPER STEM HEIGHT AND UPPER STEM DIAMETER MEASUREMENTS. THEY ARE INPUTED AS UPSHT1 AND UPSD1
C     IF THE TREE ALSO HAS BROKEN TOP HEIGHT, THE BROKEN HEIGHT IS INPUTED AS UPSHT2 AND THE UPSD2 IS SET TO 0        
      ELSEIF(UPSHT1.GT.0.1.AND.UPSD1.GT.0.1)THEN
C     &        UPSHT2.GT.0.1.AND.UPSD2.EQ.0.0)THEN
        CALL FRUSTRUM_VOL(DBHOB,DRCOB,HTTOT,UPSHT1,UPSD1,
     & UPSHT2,UPSD2,MTOPP,STUMP,VOL,ERRFLG)
C     WHEN CENTROID_HT AND CENTROID_DIA ARE MEASURED, THEY ARE INPUTED AS UPSHT2 AND UPSD2     
      ELSEIF(UPSHT2.GT.0.1.AND.UPSD2.GT.0.1)THEN
        CALL CENTROID_CV(DIA,HT,UPSD2,UPSHT2,MTOPP,STUMP,VOL,ERRFLG)
      ELSE
        CALL CONE_VOL(DBHOB,DRCOB,HTTOT,UPSHT2,UPSD2,MTOPP,
     & STUMP,VOL,ERRFLG)
      ENDIF
      RETURN
      END SUBROUTINE PACIFIC_ISLAND
      