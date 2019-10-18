! �C�E��R�� PAR �ˑ������v�Z����
! 99/05/xx �ۍ␪�G
! 99/07/23 �ۍ␪�G �T�u���[�`�����ȂǕύX
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE RAD_R_STM (
     I    NSTR           , NEND           , INSFLAG    , 
     I    MON            , NTYP           , 
     I    ZMEAN          , CVR_VEG_ms     , 
     I    EXTK           , REACH_GRD      , ZLT        , 
     I    RAD_INTO_SIB   , 
     O    R_STM_BAR_PAR     )
!
! �C�E��R�� PAR �ˑ������v�Z����
!   �Z�g���ˌv�Z���̂�? 
!
! �ۑ�  
!   ���X�e�b�v�v�Z���邩�ǂ�������
!   F    �̕ϐ����ύX
!   EXTK ���ǂ����ŕύX���Ă����B�i�����ŕύX����͕̂ρj
!        �Ƃ肠�������[�N�ɃR�s�[���ĕύX���Ďg�p
!
      USE SIBPRM , ONLY : 
     1     IDX  , 
     1     ITYP ,
     1     ICG  ,
     1     IVN  , 
     1     IBD
!
      USE SIBCON , ONLY :
     1     PIE_c  
!
      USE SIBVEG , ONLY : 
     1           GREEN_mo               , ! �����Ă��銄�� (ITYP,IMON,ICG) 
!    1           XLAI_mo                , ! LAI, �i�q���ς�!! (ITYP,IMON,ICG)
     1           CHI_L_co               , ! ��L  (ITYP,ICG) 
     1           RST_PAR_co               ! RST��PAR�ˑ��萔 (ITYP,ICG,IWV) 
!
      IMPLICIT NONE
!
!! �C�E��R�̌v�Z
!
! ����
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: INSFLAG 
!
      INTEGER,INTENT(IN)    :: NTYP  (IDX)        ! �A���^�C�v
      INTEGER,INTENT(IN)    :: MON 
!
      REAL(8),INTENT(IN)    :: ZMEAN         (IDX)
      REAL(8),INTENT(IN)    :: REACH_GRD    (IDX,IBD) 
      REAL(8),INTENT(IN)    :: RAD_INTO_SIB (IDX,IVN,IBD) 
      REAL(8),INTENT(IN)    :: CVR_VEG_ms   (IDX,ICG)
      REAL(8),intent(in)    :: ZLT   (IDX,ICG)         ! LEAF AREA INDEX 
!
! �o�� 
!
      REAL(8),INTENT(OUT)   :: 
     1      R_STM_BAR_PAR (IDX,ICG)    ! �C�E��R�iPAR �ˑ����j
!
! �ύX
      REAL(8),INTENT(IN)    :: EXTK  (IDX,ICG,IVN,IBD) 
                               ! ���͂ɂ��ׂ��B�ʂŕς��Ƃ�

!---------------------------------------------------------------->
!
! ���[�N
!
      REAL(8) :: F      ( IDX ) 
      REAL(8) :: GAMMA  ( IDX ) 
      REAL(8) :: AT     ( IDX ) 
      REAL(8) :: POWER1 ( IDX ) 
      REAL(8) :: POWER2 ( IDX ) 
      REAL(8) :: AA     ( IDX ) 
      REAL(8) :: BB     ( IDX ) 
      REAL(8) :: ZAT    ( IDX ) 
      REAL(8) :: ZK     ( IDX ) 
      REAL(8) :: EKAT   ( IDX ) 
      REAL(8) :: RHO4   ( IDX ) 
      REAL(8) :: AVFLUX ( IDX ) 
      REAL(8) :: PAR    ( IDX , ICG ) 
      REAL(8) :: PD     ( IDX , ICG ) 
      REAL(8) :: P1     ( IDX )
      REAL(8) :: P2     ( IDX )
!
      REAL(8) :: EXTK_WRK  (IDX,ICG,IVN,IBD) 
!
      INTEGER :: I
      INTEGER :: IRD
      INTEGER :: IVEG
      REAL(8) :: FCON
      REAL(8) :: FTEMP
!
      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'RAD_R_STM 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 
!
!     BOUNDING OF PRODUCT OF EXTINCTION COEFFICIENT AND LOCAL L.A.I.
!
      DO 300 I=NSTR,NEND
        F  (I)   =  MAX ( ZMEAN(I) , 0.01746D0 )
        PAR(I,1) =    RAD_INTO_SIB(I,1,1) 
     1              + RAD_INTO_SIB(I,1,2) + 0.001D0   ! ��
        PD (I,1) =  ( RAD_INTO_SIB(I,1,1) + 0.001D0 ) 
     1               / PAR(I,1) ! ���A���B�̊���
        P1 (I)   = REACH_GRD(I,1) * RAD_INTO_SIB(I,1,1) + 0.001D0    
        P2 (I)   = REACH_GRD(I,2) * RAD_INTO_SIB(I,1,2)
        PAR(I,2) = P1 (I) + P2(I)              ! ���L���m�𔲂�����
        PD (I,2) = P1 (I) / PAR(I,2)           ! ���A���B�̊���
  300 CONTINUE
!

!
      DO 100 IVEG = 1, 2-INSFLAG
      DO 100 IRD  = 1, 2
      DO 100 I=NSTR,NEND
        EXTK_WRK(I,IVEG,1,IRD)                 ! ���̕ύX PAR �ˑ����Ɏg��
     1      = MIN(  EXTK(I,IVEG,1,IRD) ,
!    1              150.0D0 / XLAI_mo(NTYP(I),MON,IVEG) 
     1              150.0D0 / ZLT(I,IVEG) 
     1                      * CVR_VEG_ms(I,IVEG) )
  100 CONTINUE
!
      FCON  = 0.25D0 * PIE_c + 0.333333D0
!
      DO 200 IVEG=1, 2-INSFLAG
      DO 200 I=NSTR,NEND
        IF ( PAR(I,IVEG).LE.0.00101D0 ) THEN
!         R_STM_BAR_PAR(I,IVEG)=1.0 D5
          R_STM_BAR_PAR(I,IVEG)=1.0 D10    ! ���]�삳��� 00/09/29 �̕ύX    
!
!!          if ( i.eq.3 ) write(6,*) 
!!     1           'rad_r_stm ISTEP',i,iveg,R_STM_BAR_PAR(I,IVEG)  

        ELSE
          GAMMA(I) = (   RST_PAR_co(NTYP(I),IVEG,1) 
     1                 + RST_PAR_co(NTYP(I),IVEG,2)
     1                    * RST_PAR_co(NTYP(I),IVEG,3)
     1               ) / RST_PAR_co(NTYP(I),IVEG,3)
!
!     SINGLE EXTINCTION COEFFICIENT USING WEIGHTED
!     VALUES OF DIRECT AND DIFFUSE CONTRIBUTIONS TO P.A.R.
!
!         AT(I) = XLAI_mo(NTYP(I),MON,IVEG) 
          AT(I) = ZLT(I,IVEG) 
     1             / CVR_VEG_ms(I,IVEG)         !radus0 nozat? L = Lg/Vg �H
!
          POWER1(I) = AT(I) * EXTK_WRK(I,IVEG,1,1)                 
          POWER2(I) = AT(I) * EXTK_WRK(I,IVEG,1,2)
!
          AA(I)=0.500D0-(0.633D0 +0.33D0 * CHI_L_co(NTYP(I),IVEG))
     1                     * CHI_L_co(NTYP(I),IVEG) 
          BB(I)=0.877D0- 1.754D0 *AA(I)                              ! ��2
!
          ZAT(I)=       LOG(( DEXP(-POWER1(I))+1.0D0 )*0.5D0 )
     &          *       PD(I,IVEG) /EXTK_WRK(I,IVEG,1,1)          !radus0��zat 
          ZAT(I)=ZAT(I)+LOG(( DEXP(-POWER2(I))+1.0D0 )*0.5D0 )
     &          *( 1.0D0 -PD(I,IVEG))/EXTK_WRK(I,IVEG,1,2)
!
          ZK(I)=1.0D0 / ZAT(I)
     &     * LOG(  PD(I,IVEG) *DEXP( POWER1(I)*ZAT(I)/AT(I) )
     &      +(1.0D0 -PD(I,IVEG))*DEXP( POWER2(I)*ZAT(I)/AT(I) ))
!
!     CANOPY AND GROUND COVER BULK RESISTANCES USING
!     ROSS-GOUDRIAAN LEAF FUNCTION , TOTAL PAR FLUX (AVFLUX) AND
!     MEAN EXTINCTION COEFFICIENT (ZK)
!
          FTEMP     = MIN( ZK(I)*AT(I),20.0D0 )
          EKAT  (I) = DEXP( FTEMP )
          AVFLUX(I) = PAR(I,IVEG)*( PD(I,IVEG)*( AA(I)/F(I)+BB(I))
     &         +( 1.0D0 -PD(I,IVEG))*( BB(I)*FCON+AA(I)*1.5D0 ))
          RHO4  (I) = GAMMA(I) / AVFLUX(I)
!
          R_STM_BAR_PAR(I,IVEG) 
     1              = RST_PAR_co(NTYP(I),IVEG,2)
     1                  / GAMMA(I) * LOG( (RHO4(I)*EKAT(I)+1.0D0 )
     1                                   / (RHO4(I)+1.0D0 )      )
          R_STM_BAR_PAR(I,IVEG) = R_STM_BAR_PAR(I,IVEG)
     1                - LOG((RHO4(I)+1.0D0 /EKAT(I))/(RHO4(I)+1.0D0 ))      
          R_STM_BAR_PAR(I,IVEG) = R_STM_BAR_PAR(I,IVEG)
     1                  / ( ZK(I)*RST_PAR_co(NTYP(I),IVEG,3) )
!
          R_STM_BAR_PAR(I,IVEG) = 
     1         1.0D0 
     1         / ( R_STM_BAR_PAR(I,IVEG)*GREEN_mo(NTYP(I),MON,IVEG) )
!
!!          if ( i.eq.3 ) write(6,*) 
!!     1           'rad_r_stm ISTEP',i,iveg,R_STM_BAR_PAR(I,IVEG)  
        END IF
 200  CONTINUE
!
      RETURN
      END