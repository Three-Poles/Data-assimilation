! ��̒Z�g�A���x�h�E�z���֘A�萔�̐ݒ�B SNWALB 
! 99/05/xx �ۍ␪�G  ����
! 99/07/11 �ۍ␪�G      
! 99/07/23 �ۍ␪�G  �䗦�v�Z�폜    
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 
      SUBROUTINE ALBEDO_SNOW  ( 
     I    NMAX        , 
     I    NMAX_01     , 
     I    NTYP        , 
     I    TMP_SNSK    , AGE_SNOW   , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     I    RAIN_1HOUR  ,  
     M    ALB_SNOW_SNW, ALB_SNOW_NOS,
     M    ALB_SNOW_onCNP_SNW  , ALB_SNOW_onCNP_NOS ) 
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IVN     
!
      USE SIBCON , ONLY : 
     1    ITUNE_ALBEDO_SNOW      
!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN)   :: NMAX                   
      INTEGER,INTENT(IN)   :: NMAX_01 (3)                   
      INTEGER,INTENT(IN)   :: NTYP    (IDX)      ! �A���^�C�v
!
      REAL(8),INTENT(INOUT):: AGE_SNOW (IDX)     ! �\�ʂ̐�̌o�ߎ���
      REAL(8),INTENT(IN)   :: TMP_SNSK (IDX)     ! ��̕\�ʉ��x

      REAL(8),INTENT(IN)   :: TMP_CNP_NOS (IDX)  ! �ᖳ���L���m�s�[���x
      REAL(8),INTENT(IN)   :: TMP_CNP_SNW (IDX)  ! �Ⴀ��L���m�s�[���x
!
! OUTPUT 
!
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_SNW (IDX,IVN)  ! ��ʃA���x�h
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_NOS (IDX,IVN)  
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_onCNP_SNW (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_onCNP_NOS (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
      REAL(8),INTENT(IN)     :: RAIN_1HOUR (IDX) 
!
      IF ( ITUNE_ALBEDO_SNOW .EQ. 0 ) THEN     ! JMA ���[�`������
        CALL ALBEDO_SNOW_0   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     O    ALB_SNOW_SNW, ALB_SNOW_NOS,
     O    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
!
      ELSEIF ( ITUNE_ALBEDO_SNOW .EQ. 1 ) THEN   ! ����������� 1 
        CALL ALBEDO_SNOW_1   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , AGE_SNOW   , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     O    ALB_SNOW_SNW, ALB_SNOW_NOS,
     O    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
!
      ELSEIF ( ITUNE_ALBEDO_SNOW .EQ. 2 ) THEN   ! MJ98 ����
        CALL ALBEDO_SNOW_2   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     O    ALB_SNOW_SNW, ALB_SNOW_NOS,
     O    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
!
      ELSEIF (      ITUNE_ALBEDO_SNOW .EQ. 3 
     1         .OR. ITUNE_ALBEDO_SNOW .EQ. 4 ) THEN   ! ����������� 2 (�ϕ�)
        CALL ALBEDO_SNOW_3   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , 
     I    RAIN_1HOUR  , 
     M    AGE_SNOW   , 
!     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     M    ALB_SNOW_SNW, ALB_SNOW_NOS,
     M    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
      ENDIF 
!
      RETURN
      END
!=====================================================================
      SUBROUTINE ALBEDO_SNOW_0   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     O    ALB_SNOW_SNW, ALB_SNOW_NOS,
     O    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
!
! JMA ���[�`������
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IVN     
!
      USE SIBCON , ONLY : 
     1    TMP_FREZ_c           , 
     1    ALB_SNOW_VIS_c       ,
     1    ALB_SNOW_NIR_c       ,
     1    ALB_SNOW_FACT_TEMP_c    
!
      use sibveg , only : ityp_glacier 
!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN)   :: NMAX                   
      INTEGER,INTENT(IN)   :: NMAX_01 (3)                   
      INTEGER,INTENT(IN)   :: NTYP    (IDX)       ! �A���^�C�v
!
      REAL(8),INTENT(IN)   :: TMP_SNSK(IDX)       ! ��̕\�ʉ��x

      REAL(8),INTENT(IN)   :: TMP_CNP_NOS (IDX)  ! �ᖳ���L���m�s�[���x
      REAL(8),INTENT(IN)   :: TMP_CNP_SNW (IDX)  ! �Ⴀ��L���m�s�[���x
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: ALB_SNOW_SNW (IDX,IVN)  ! ��ʃA���x�h
      REAL(8),INTENT(OUT)  :: ALB_SNOW_NOS (IDX,IVN)  
      REAL(8),INTENT(OUT)  :: ALB_SNOW_onCNP_SNW (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
      REAL(8),INTENT(OUT)  :: ALB_SNOW_onCNP_NOS (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
! WORK 
!
      LOGICAL,SAVE :: LFIRST = .TRUE. 
      REAL(8)      ::     DELTG             ! ���x��
      REAL(8)      ::     FWAVE 
      real(8)      ::     ALBSNW

      INTEGER :: I , JVN 
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'ALBEDO_SNOW_0 ROUTINE type'
        WRITE(6,*) ' ALBEDO DEPENDS ON WAVE_LENGTH AND TEMP.'
        WRITE(6,*) '  VIS = ' , ALB_SNOW_VIS_c
        WRITE(6,*) '  NIR = ' , ALB_SNOW_NIR_c
        WRITE(6,*) '  FACT_TEMP = ' , ALB_SNOW_FACT_TEMP_c 
        LFIRST = .FALSE. 
      ENDIF
!
      alb_snow_nos(:,:) = 0. 
      alb_snow_snw(:,:) = 0. 
      alb_snow_oncnp_nos(:,:) = 0. 
      alb_snow_oncnp_snw(:,:) = 0. 
!  
      DO JVN = 1, 2                         ! ���E�ߐ�
!
! ------------
! > �Ⴀ��� <
! ------------
!
        DO I=NMAX_01(2),NMAX
!
!  �����
!
!     �g���ˑ���
!
          IF      ( JVN .EQ. 1 ) THEN  ! ��
            FWAVE = ALB_SNOW_VIS_c
          ELSEIF  ( JVN .EQ. 2 ) THEN  ! �ߐԊO
            FWAVE = ALB_SNOW_NIR_c
          ENDIF
!
!     ���x�ˑ���
!
          DELTG = TMP_FREZ_c - TMP_SNSK(I)           
          IF ( DELTG.LT.0.05D0 ) THEN
            ALBSNW = FWAVE * ALB_SNOW_FACT_TEMP_C
          ELSE
            ALBSNW = FWAVE 
          END IF
!
!     �X����̗�O����
!
          IF ( (NTYP(I).EQ.ityp_glacier).AND.(JVN.EQ.1) ) THEN 
            IF ( DELTG.LT.0.05D0 ) THEN
              ALBSNW = 0.95D0 * 0.8D0   
            ELSE
              ALBSNW = 0.95D0 * 1.0D0   
            END IF
          ENDIF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_SNW (I,JVN) = ALBSNW 
!
!  ���L���m�s�[
!
!     �g���ˑ���
!  
          IF      ( JVN .EQ. 1 ) THEN  ! ��
            FWAVE = ALB_SNOW_VIS_c
          ELSEIF  ( JVN .EQ. 2 ) THEN  ! �ߐԊO
            FWAVE = ALB_SNOW_NIR_c
          ENDIF
!
!     ���x�ˑ��� ( 0 �x�ɋ߂��Ƃ��̓t�@�N�^�������� ) 
!
          DELTG = TMP_FREZ_c - TMP_CNP_SNW(I)         
          IF ( DELTG.LT.0.05D0 ) THEN
            ALBSNW = FWAVE * ALB_SNOW_FACT_TEMP_c 
          ELSE
            ALBSNW = FWAVE 
          END IF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_onCNP_SNW (I,JVN) = ALBSNW  
        ENDDO
!
! ------------
! > ��Ȃ��� <  ( �L���m�s�[�̂� ) 
! ------------
!
        DO I=1,NMAX_01(3)
!
!     �g���ˑ���
! 
          IF      ( JVN .EQ. 1 ) THEN  ! ��
            FWAVE = ALB_SNOW_VIS_c
          ELSEIF  ( JVN .EQ. 2 ) THEN  ! �ߐԊO
            FWAVE = ALB_SNOW_NIR_c
          ENDIF
!
!     ���x�ˑ���
!
          DELTG = TMP_FREZ_c - TMP_CNP_NOS(I)           
          IF ( DELTG.LT.0.05D0 ) THEN
            ALBSNW = FWAVE * ALB_SNOW_FACT_TEMP_c
          ELSE
            ALBSNW = FWAVE 
          END IF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_onCNP_NOS (I,JVN) = ALBSNW  
          ALB_SNOW_NOS       (I,JVN) = ALBSNW   !dummy
        ENDDO
!
      ENDDO           
!
      RETURN 
      END SUBROUTINE ALBEDO_SNOW_0
!=====================================================================
      SUBROUTINE ALBEDO_SNOW_1   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , AGE_SNOW   , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     O    ALB_SNOW_SNW, ALB_SNOW_NOS,
     O    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
!
! JMA ���[�`������
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IVN     
!
      USE SIBCON , ONLY : 
     1    TMP_FREZ_c             , 
     1    AGE_SNOW_MAX1_c        , 
     1    AGE_SNOW_ETIME_INV_c   ,
     1    ALB_SNOW_VIS_INI_c     ,
     1    ALB_SNOW_VIS_FOR_c     ,
     1    ALB_SNOW_NIR_INI_c     ,
     1    ALB_SNOW_NIR_FOR_c     ,
     1    ALB_SNOW_FACT_TEMP_c

!
      use sibveg , only : ityp_glacier 

!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN)   :: NMAX                   
      INTEGER,INTENT(IN)   :: NMAX_01 (3)                   
      INTEGER,INTENT(IN)   :: NTYP    (IDX)       ! �A���^�C�v
!
      REAL(8),INTENT(IN)   :: AGE_SNOW (IDX)      ! �\�ʂ̐�̌o�ߎ���
      REAL(8),INTENT(IN)   :: TMP_SNSK(IDX)       ! ��̕\�ʉ��x

      REAL(8),INTENT(IN)   :: TMP_CNP_NOS (IDX)  ! �ᖳ���L���m�s�[���x
      REAL(8),INTENT(IN)   :: TMP_CNP_SNW (IDX)  ! �Ⴀ��L���m�s�[���x
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: ALB_SNOW_SNW (IDX,IVN)  ! ��ʃA���x�h
      REAL(8),INTENT(OUT)  :: ALB_SNOW_NOS (IDX,IVN)  
      REAL(8),INTENT(OUT)  :: ALB_SNOW_onCNP_SNW (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
      REAL(8),INTENT(OUT)  :: ALB_SNOW_onCNP_NOS (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
!
! SAVE 
!
      REAL(8),SAVE   ::  ALB_INI(IVN)      ! �A���x�h�����l
      REAL(8),SAVE   ::  ALB_FOR(IVN)      ! �A���x�h�������l
      REAL(8),SAVE   ::  ALB_END(IVN)      ! �A���x�h�ŏI�l
!
! WORK 
!
      REAL(8)      :: DELTG 
      LOGICAL,SAVE :: LFIRST = .TRUE. 
      INTEGER :: I , JVN 
!
      IF ( LFIRST ) THEN
        ALB_INI(1) = ALB_SNOW_VIS_INI_c     ! ���A���x�h�����l    0.95
        ALB_INI(2) = ALB_SNOW_NIR_INI_c     ! �ߐԃA���x�h�����l    0.75 
        ALB_FOR(1) = ALB_SNOW_VIS_FOR_c     ! ���A���x�h�������l  0.65 
        ALB_FOR(2) = ALB_SNOW_NIR_FOR_c     ! �ߐԃA���x�h�������l  0.45 
!
        ALB_END(1) = ALB_FOR(1) 
     1              + ( ALB_INI(1) - ALB_FOR(1) ) 
     1             * DEXP ( - AGE_SNOW_MAX1_c * AGE_SNOW_ETIME_INV_c )
        ALB_END(2) = ALB_FOR(2) 
     1              + ( ALB_INI(2) - ALB_FOR(2) ) 
     1             * DEXP ( - AGE_SNOW_MAX1_c * AGE_SNOW_ETIME_INV_c)
!
        write(6,*) 'albedo_snow etime' , 1/ AGE_SNOW_ETIME_INV_c
        write(6,*) 'albedo_snow VIS : ini for end' , 
     1                alb_ini(1), alb_for(1), alb_end(1) 
        write(6,*) 'albedo_snow IR  : ini for end' , 
     1                alb_ini(2), alb_for(2), alb_end(2) 
        LFIRST = .FALSE. 
      ENDIF
!
      alb_snow_nos(:,:) = 0. 
      alb_snow_snw(:,:) = 0. 
      alb_snow_oncnp_nos(:,:) = 0. 
      alb_snow_oncnp_snw(:,:) = 0. 
!
      DO JVN = 1, 2
!
!  ==================
!  >> �A���x�h�v�Z <<
!  ==================
!
!  ----------------------------
!  > �ᖳ���� ( onCNP �̂� ) <
!  ----------------------------
!
        DO I=1,NMAX_01(3)
          ALB_SNOW_onCNP_NOS (I,JVN) = ALB_END(JVN) 
          ALB_SNOW_NOS       (I,JVN) = ALB_END(JVN)    ! �_�~�[
!
          DELTG = TMP_FREZ_c - TMP_CNP_NOS(I)             
          IF ( DELTG.LT.0.05D0 ) THEN                  ! �ʂ��
            ALB_SNOW_onCNP_NOS(I,JVN) 
!    1          = ALB_SNOW_onCNP_NOS(I,JVN) * 0.6 
     1          = ALB_SNOW_onCNP_NOS(I,JVN) * ALB_SNOW_FACT_TEMP_c 
          END IF
        ENDDO
!
!  -------------
!  > �Ⴀ���  <
!  -------------
!     �V��Ȃ玞�Ԃɂ��� exp �Ō�������B����Ȃ�萔�B
!
        DO I=NMAX_01(2),NMAX
!
!  �x�[�X
!
          IF ( AGE_SNOW(I) .GT. AGE_SNOW_MAX1_c ) THEN
            ALB_SNOW_SNW(I,JVN) = ALB_END(JVN)
          ELSE 
            ALB_SNOW_SNW(I,JVN) = ALB_FOR(JVN) 
     1                + ( ALB_INI(JVN) - ALB_FOR(JVN) ) 
     1                  * DEXP ( - AGE_SNOW(I) * AGE_SNOW_ETIME_INV_c )
          ENDIF
!
!  �L���m�s�[
!
          ALB_SNOW_onCNP_SNW(I,JVN) = ALB_SNOW_SNW(I,JVN)
          DELTG = TMP_FREZ_c - TMP_CNP_SNW(I)             
          IF ( DELTG.LT.0.05D0 ) THEN                   ! �ʂ��
            ALB_SNOW_onCNP_SNW(I,JVN) 
!    1             = ALB_SNOW_onCNP_SNW(I,JVN) * 0.6D0           
     1             = ALB_SNOW_onCNP_SNW(I,JVN) * ALB_SNOW_FACT_TEMP_c           
          END IF
!
!  ���
!
          DELTG   =  TMP_FREZ_c - TMP_SNSK(I)           
          IF ( DELTG.LT.0.05D0 ) THEN                 
!           ALB_SNOW_SNW(I,JVN) = ALB_SNOW_SNW(I,JVN) * 0.6            
            ALB_SNOW_SNW(I,JVN) = ALB_SNOW_SNW(I,JVN) * 
     1                                         ALB_SNOW_FACT_TEMP_c            
          END IF
!
! ----------------------
! > �X���A���x�h�̕␳ <
! ----------------------
!    ��ʉ��̂݁B�L���m�s�[�͂����������܂�Ȃ����낤����A�␳�Ȃ��B
!
          IF ( ( NTYP(I).EQ.ityp_glacier).AND.(JVN.EQ.1) ) THEN 
            IF ( DELTG.LT.0.05D0 ) THEN
              ALB_SNOW_SNW(I,JVN) = 0.95D0 * 0.8D0   
            ELSE
              ALB_SNOW_SNW(I,JVN) = 0.95D0 * 1.0D0   
            END IF
          ENDIF
!
        ENDDO
!
      ENDDO
!
      RETURN 
      END SUBROUTINE ALBEDO_SNOW_1
!=====================================================================
      SUBROUTINE ALBEDO_SNOW_2   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , 
     I    TMP_CNP_SNW , TMP_CNP_NOS, 
     O    ALB_SNOW_SNW, ALB_SNOW_NOS,
     O    ALB_SNOW_onCNP_SNW       , ALB_SNOW_onCNP_NOS        ) 
!
!  For MRI/JMA98 ( �s�{ L3SiB �`���[�j���O ) 
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IVN     
!
      USE SIBCON , ONLY : 
     1    TMP_FREZ_c           , 
     1    ALB_SNOW_VIS_c       ,
     1    ALB_SNOW_NIR_c       ,
     1    ALB_SNOW_FACT_TEMP_c   , 
     1    ALB_SNOW_VIS_FOR_c     ,
     1    ALB_SNOW_NIR_FOR_c     
!
      use sibveg , only : ityp_glacier 

!
      IMPLICIT NONE
!
! INPUT
!
      INTEGER,INTENT(IN)   :: NMAX                   
      INTEGER,INTENT(IN)   :: NMAX_01 (3)                   
      INTEGER,INTENT(IN)   :: NTYP    (IDX)       ! �A���^�C�v
!
      REAL(8),INTENT(IN)   :: TMP_SNSK(IDX)       ! ��̕\�ʉ��x

      REAL(8),INTENT(IN)   :: TMP_CNP_NOS (IDX)  ! �ᖳ���L���m�s�[���x
      REAL(8),INTENT(IN)   :: TMP_CNP_SNW (IDX)  ! �Ⴀ��L���m�s�[���x
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: ALB_SNOW_SNW (IDX,IVN)  ! ��ʃA���x�h
      REAL(8),INTENT(OUT)  :: ALB_SNOW_NOS (IDX,IVN)  
      REAL(8),INTENT(OUT)  :: ALB_SNOW_onCNP_SNW (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
      REAL(8),INTENT(OUT)  :: ALB_SNOW_onCNP_NOS (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
!
! WORK 
!
      LOGICAL,SAVE :: LFIRST = .TRUE. 
      REAL(8)      :: ALBXX 
      REAL(8)      :: ALBSNW
      REAL(8)      :: FWAVE
      INTEGER :: I , JVN 
    
!
      IF ( LFIRST ) THEN  
        WRITE(6,*) 'ALBEDO_SNOW_2 : ' , 
     1             ' ALBEDO DEPENDS ON WAVE_LENGTH AND TEMP.'
        WRITE(6,*) '  VIS = ' , ALB_SNOW_VIS_c
        WRITE(6,*) '  NIR = ' , ALB_SNOW_NIR_c
        WRITE(6,*) '  FACT_TEMP = ' , ALB_SNOW_FACT_TEMP_c 
        LFIRST = .FALSE. 
      ENDIF
!
      alb_snow_nos(:,:) = 0. 
      alb_snow_snw(:,:) = 0. 
      alb_snow_oncnp_nos(:,:) = 0. 
      alb_snow_oncnp_snw(:,:) = 0. 
!
! ------------
! > �Ⴀ��� <
! ------------
!
      DO JVN=1,IVN
        DO I=NMAX_01(2),NMAX
!
!  �����
!
!     �g���ˑ���
!
          IF      ( JVN .EQ. 1 ) THEN  ! ��
            FWAVE = ALB_SNOW_VIS_c
          ELSEIF  ( JVN .EQ. 2 ) THEN  ! �ߐԊO
            FWAVE = ALB_SNOW_NIR_c
          ENDIF
!
!     ���x�ˑ���
!
!!          DELTG = TMP_FREZ_c - TMP_SNSK(I)           
!!          IF ( DELTG.LT.0.05D0 ) THEN
!!            ALBSNW = FWAVE * ALB_SNOW_FACT_TEMP_C
!!          ELSE
!!            ALBSNW = FWAVE 
!!          END IF
          ALBXX = 1.D0 - ( TMP_SNSK(I) -269.1D0 ) * 0.05
          ALBXX = MAX(0.7D0,MIN(1.D0,ALBXX))
          ALBSNW = FWAVE * ALBXX 
!
!     �X����̗�O����
!
!!          IF ( (NTYP(I).EQ.25).AND.(JVN.EQ.1) ) THEN 
!!            IF ( DELTG.LT.0.05D0 ) THEN
!!              ALBSNW = 0.95D0 * 0.8D0   
!!            ELSE
!!              ALBSNW = 0.95D0 * 1.0D0   
!!            END IF
!!          ENDIF
!
          IF ( NTYP(I).EQ.ityp_glacier ) THEN
            IF (JVN.EQ.1) THEN 
              ALBSNW = 0.95D0 
            ELSE
              ALBXX = 0.4D0 + (270.D0-TMP_SNSK(I))*0.2D0
              ALBSNW = MAX ( 0.4D0, MIN(0.7D0,ALBXX))
            END IF
          ENDIF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_SNW (I,JVN) = ALBSNW 
!
!  ���L���m�s�[
!
!     �g���ˑ���
!  
          IF      ( JVN .EQ. 1 ) THEN  ! ��
            FWAVE = ALB_SNOW_VIS_c
          ELSEIF  ( JVN .EQ. 2 ) THEN  ! �ߐԊO
            FWAVE = ALB_SNOW_NIR_c
          ENDIF
!
!     ���x�ˑ��� ( 0 �x�ɋ߂��Ƃ��̓t�@�N�^�������� ) 
!
!!          DELTG = TMP_FREZ_c - TMP_CNP_SNW(I)         
!!          IF ( DELTG.LT.0.05D0 ) THEN
!!            ALBSNW = FWAVE * ALB_SNOW_FACT_TEMP_c 
!!          ELSE
!!            ALBSNW = FWAVE 
!!          END IF
!
          ALBXX = 1.D0 - ( TMP_SNSK(I) -269.1D0 ) * 0.05
          ALBXX = MAX(0.7D0,MIN(1.D0,ALBXX))
          ALBSNW = FWAVE * ALBXX 
!
          IF ( NTYP(I).EQ.ityp_glacier ) THEN
            IF (JVN.EQ.1) THEN 
              ALBSNW = 0.95D0 
            ELSE
              ALBXX = 0.4D0 + (270.D0-TMP_SNSK(I))*0.2D0
              ALBSNW = MAX ( 0.4D0, MIN(0.7D0,ALBXX))
            END IF
          ENDIF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_onCNP_SNW (I,JVN) = ALBSNW  
        ENDDO
!
! ------------
! > ��Ȃ��� <  ( �L���m�s�[�̂� ) 
! ------------
!
        DO I=1,NMAX_01(3)
!
!     �g���ˑ���
! 
          IF      ( JVN .EQ. 1 ) THEN  ! ��
            FWAVE = ALB_SNOW_VIS_c
          ELSEIF  ( JVN .EQ. 2 ) THEN  ! �ߐԊO
            FWAVE = ALB_SNOW_NIR_c
          ENDIF
!
!     ���x�ˑ���
!
!!          DELTG = TMP_FREZ_c - TMP_CNP_NOS(I)           
!!          IF ( DELTG.LT.0.05D0 ) THEN
!!            ALBSNW = FWAVE * ALB_SNOW_FACT_TEMP_c
!!          ELSE
!!            ALBSNW = FWAVE 
!!          END IF
!
          ALBXX = 1.D0 - ( TMP_SNSK(I) -269.1D0 ) * 0.05
          ALBXX = MAX(0.7D0,MIN(1.D0,ALBXX))
          ALBSNW = FWAVE * ALBXX 
!
          IF ( NTYP(I).EQ.ityp_glacier ) THEN
            IF (JVN.EQ.1) THEN 
              ALBSNW = 0.95D0 
            ELSE
              ALBXX = 0.4D0 + (270.D0-TMP_SNSK(I))*0.2D0
              ALBSNW = MAX ( 0.4D0, MIN(0.7D0,ALBXX))
            END IF
          ENDIF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_onCNP_NOS (I,JVN) = ALBSNW  
          ALB_SNOW_NOS       (I,JVN) = ALBSNW   !dummy
        ENDDO
!
      ENDDO           
!
      RETURN 
      END SUBROUTINE ALBEDO_SNOW_2
!=====================================================================
      SUBROUTINE ALBEDO_SNOW_3   ( 
     I    NMAX        , NMAX_01    , 
     I    NTYP        , 
     I    TMP_SNSK    , 
     I    RAIN_1HOUR  , 
     M    AGE_SNOW    , 
!     I    TMP_CNP_SNW , TMP_CNP_NOS , 
     M    ALB_SNOW_SNW, ALB_SNOW_NOS,
     M    ALB_SNOW_onCNP_SNW        , ALB_SNOW_onCNP_NOS        ) 
!
!  T.Aoki et al. (2003) ����
!    �N��́A�Ⴂ ( 1 ���Ԉȉ� ) ���ǂ����̏��݂̂��g�p����B
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IVN     
!
      USE SIBCON , ONLY : 
     1    TMP_FREZ_c             , 
     1    ALB_SNOW_VIS_FOR_c     ,
     1    ALB_SNOW_NIR_FOR_c     ,
     1    ITUNE_ALBEDO_SNOW      ,
     1    RAIN_1HOUR_FRESH_c     ,
     1    AGE_SNOW_MAX2_c     
!
!
      use sibveg , only : ityp_glacier 

! INPUT
!
      INTEGER,INTENT(IN)   :: NMAX                   
      INTEGER,INTENT(IN)   :: NMAX_01 (3)                   
      INTEGER,INTENT(IN)   :: NTYP    (IDX)      ! �A���^�C�v
!
      REAL(8),INTENT(IN)   :: TMP_SNSK (IDX)     ! ��̕\�ʉ��x
!
      REAL(8),INTENT(IN)   :: RAIN_1HOUR (IDX)  

!      REAL(8),INTENT(IN)   :: TMP_CNP_NOS (IDX)  ! �ᖳ���L���m�s�[���x
!      REAL(8),INTENT(IN)   :: TMP_CNP_SNW (IDX)  ! �Ⴀ��L���m�s�[���x
!
! OUTPUT 
!
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_SNW (IDX,IVN)  ! ��ʃA���x�h
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_NOS (IDX,IVN)  
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_onCNP_SNW (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
      REAL(8),INTENT(INOUT)  :: ALB_SNOW_onCNP_NOS (IDX,IVN) 
!                                                 ! �L���̗t�̐�̃A���x�h
!
      REAL(8),INTENT(INOUT)  :: AGE_SNOW (IDX) 

!
      REAL(8),SAVE :: DELT_CALC_ALBEDO = 3600.D0   ! unit sec 
                                       ! 1 ���ԂɈ�x�̌v�Z������
!
! SAVE 
!
!      REAL(8),SAVE   ::  ALB_STR(IVN)      ! �����l
      REAL(8),SAVE   ::  ALB_END(IVN)      ! �ŏ��l
!
      LOGICAL,SAVE   :: LFIRST = .TRUE. 
!
! WORK 
!
      REAL(8)      :: DEL 
      REAL(8)      :: ALBSNW 
      INTEGER      :: I , JVN 
      real(8),parameter :: zero = 0.D0 
      real(8),parameter :: one  = 1.D0 
      REAL(8)      :: TMP
      REAL(8)      :: ALBXX
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'ALBEDO_SNOW_3 Aoki type ' , itune_albedo_snow 
        LFIRST = .FALSE. 
        ALB_END(1) = ALB_SNOW_VIS_FOR_c 
        ALB_END(2) = ALB_SNOW_NIR_FOR_c 
!
        write(6,*) '   visible goto ' , alb_end(1) 
        write(6,*) '   ir      goto ' , alb_end(2) 
!        ALB_STR(1) = ALB_SNOW_VIS_INI_c 
!        ALB_STR(2) = ALB_SNOW_NIR_INI_c 
      ENDIF
!
      DO I=1,NMAX_01(2)-1
        AGE_SNOW     (I) = AGE_SNOW_MAX2_c
      ENDDO
      DO I=NMAX_01(2),NMAX 
        AGE_SNOW     (I) = AGE_SNOW     (I)  + DELT_CALC_ALBEDO
        AGE_SNOW     (I) = MIN ( AGE_SNOW(I) , AGE_SNOW_MAX2_c)
      ENDDO
!
! �v�Z����
!   ��{�I�ɂ͗\�������
!   �N��Ⴏ��� ( 1 ���Ԉȓ� ) �V�l�Ƀ��Z�b�g����B
!     
      DO JVN = 1, 2                         ! ���E�ߐ�
!
! ------------
! > ��Ȃ��� <  ( �L���m�s�[�̂݁B�����l��^����B) 
! ------------
!
        DO I=1,NMAX_01(3)
!
!     �g���ˑ���
! 
          ALBSNW = ALB_END(JVN) 
!
!     ���x�ˑ��� ( �G��� ) 
!         DELTG = TMP_FREZ_c - TMP_CNP_NOS(I)           
!         IF ( DELTG.LT.0.05D0 ) THEN
!           ALBSNW = ALBSNW * ALB_SNOW_FACT_TEMP_c
!         END IF
!
!     �A���x�h�l�ݒ�
!
          ALB_SNOW_onCNP_NOS (I,JVN) = ALBSNW  
          ALB_SNOW_NOS       (I,JVN) = ALBSNW   !dummy
!
        ENDDO
!
! ------------
! > �Ⴀ��� <
! ------------
!
        DO I=NMAX_01(2),NMAX
!
!  �����
!     
!      �A���x�h���� ( 1 ���ԓ����� )    
!
          IF     ( TMP_SNSK(I) - TMP_FREZ_c .LT. -20 ) THEN
            DEL = - 0.321D-4 * ( DELT_CALC_ALBEDO / 3600.D0 )
          ELSEIF ( TMP_SNSK(I) - TMP_FREZ_c .LT. -10 ) THEN
            DEL = - 1.60 D-4 * ( DELT_CALC_ALBEDO / 3600.D0 )
          ELSEIF ( TMP_SNSK(I) - TMP_FREZ_c .LT. - 5 ) THEN
            DEL = - 4.33 D-4 * ( DELT_CALC_ALBEDO / 3600.D0 )
          ELSE
            DEL = - 7.18 D-4 * ( DELT_CALC_ALBEDO / 3600.D0 )
          ENDIF
          DEL = DEL * ( 0.4 + JVN * 0.4 )   ! �� 1 �� 0.8 , �ߐ� 2 �� 1.2
!
!      ���Ԑϕ�
!
          ALB_SNOW_SNW (I,JVN) = ALB_SNOW_SNW (I,JVN) + DEL 
!
!      ��������
!
          ALB_SNOW_SNW (I,JVN) 
     1         = MAX ( ALB_SNOW_SNW (I,JVN) , ALB_END(JVN) )
!
!      �V�᎞�̓��Z�b�g
!        �� : -2.5 �x�� 0.9 , -7.5 �x 0.95
!        �ߐ� : -2.5 �x�� 0.7 , -7.5 �x 0.75
!
!         IF ( AGE_SNOW (I) .LT. DELT_CALC_ALBEDO - 0.1 ) THEN
          IF ( RAIN_1HOUR (I) .GT. RAIN_1HOUR_FRESH_c ) THEN
!
!               TMP : -2.5 ��荂�� �� 0 , -7.5 ���Ⴂ �� 1 
!               ��(1) 0.95or0.9 ����A�ߐ�(2) : 0.75or0.7 ����
!
            TMP =  - ( TMP_SNSK(I) - TMP_FREZ_c + 2.5 )/5  
            TMP = MIN ( MAX ( TMP , ZERO ) , ONE ) 

            ALB_SNOW_SNW(I,JVN) = TMP * 0.05 + 1.1 - JVN * 0.2  
            AGE_SNOW    (I)     = 0. 
!
          ENDIF 
!
          ALB_SNOW_onCNP_SNW (I,JVN) = ALB_SNOW_SNW(I,JVN) 
!
        ENDDO
!
!     �X����̗�O���� ( ITUNE_ALBEDO_SNOW .EQ. 4 �̂Ƃ��̂� ) 
!
        IF ( ITUNE_ALBEDO_SNOW .EQ. 4 ) THEN
        DO I=NMAX_01(2),NMAX
          IF ( NTYP(I).EQ.ityp_glacier ) THEN
            IF (JVN.EQ.1) THEN 
              ALBSNW = 0.95D0 
            ELSE
              ALBXX = 0.4D0 + (270.D0-TMP_SNSK(I))*0.2D0
              ALBSNW = MAX ( 0.4D0, MIN(0.7D0,ALBXX))
            END IF
          ENDIF
        ENDDO
        ENDIF
!
      ENDDO           
!
      RETURN
      END SUBROUTINE ALBEDO_SNOW_3   
