! module com_step 
! 99/07/20 �ۍ␪�G  ���f���̂����K�v�Ȃ��̂�؂�o���B
!                    ICN_SIB_CALC_SOIL_SNOW �� ICNSW_NEXT �͐V�K�쐬
!
!  �e���f���Ή��� COM_STEP_SIB0007_RUN_* ���K�v
!  �Ƃɂ������O�� 31 �����܂łɗ��߂܂��傤
!
      MODULE COM_STEP_SIB0109 
!
      IMPLICIT NONE
!
!                      1234567890123456789012345678901
      INTEGER,SAVE  :: ICN_SIB0109_CALC_SOIL_SNOW    ! SiB �œy��E��̌v�Z
      INTEGER,SAVE  :: ICN_SIB0109_SNOW_RESET     =0 ! ��w�����Z�b�g
      INTEGER,SAVE  :: ICN_SIB0109_AFTER_CALC_SOIL_SNW  
                                                     ! SiB �œy��E��̌v�Z����
                                                     ! ���̃X�e�b�v
      INTEGER,SAVE  :: ICN_SIB0109_SW                ! �Z�g�v�Z����X�e�b�v
      INTEGER,SAVE  :: ICN_SIB0109_LW                ! ���g�v�Z����X�e�b�v
!
      INTEGER,SAVE  :: ICN_SIB0109_MONITOR           ! ���j�^�o�͂���X�e�b�v
!
      REAL(8),SAVE  :: SCN_SIB0109_DELT            ! ���ԍ�
      REAL(8),SAVE  :: SCN_SIB0109_DELT_ATM        ! ��C�̎��ԍ� 
                                                   !  or ���[�v�t���b�O�̂Ƃ�
      REAL(8),SAVE  :: SCN_SIB0109_DELT_SR         ! �Z�g�̎��ԍ� ( 1 hour ? )
!
      INTEGER,SAVE  :: ICN_SIB0109_FIRST_STEP        ! �W���u�̑��X�e�b�v 
      INTEGER,SAVE  :: ICN_SIB0109_LAST_STEP         ! �W���u�̍ŏI�X�e�b�v 
!
      contains 
!===================================================================
      SUBROUTINE COM_STEP_SIB0109_RUN  (
     I    FSECP ) 
!
      USE COM_RUNCONF_SIB0109 , ONLY : 
     I    JCN_IWL_SKIP      ,
     I    RCN_DELT_CNP      ,  
     I    RCN_DELT_SOIL     ,
     1    RCN_DELT_SR     
!
      USE COM_STEP , ONLY :
     I    ICNSW   , 
     I    ICNIR   , 
     I    ICNMNTMON , 
     I    SCN_DELT  , 
     I    SCN_2DELTX ,
!    I    SCNDTSW   ,
     I    ICNFST  ,
     I    ICNLAST

!
!
      IMPLICIT NONE
!
      real(8),intent(in) :: fsecp
      integer  :: is 
!
      logical , save :: lfirst = .true. 
!
!   �y��E����v�Z��������t���O
!
      IF ( LFIRST ) THEN
        ICN_SIB0109_AFTER_CALC_SOIL_SNW = 1 
        lfirst = .false. 
      ELSE 
        ICN_SIB0109_AFTER_CALC_SOIL_SNW = ICN_SIB0109_CALC_SOIL_SNOW 
      ENDIF 
!
      IF     ( 
     1              JCN_IWL_SKIP.EQ.1 .OR. JCN_IWL_SKIP.EQ.-1 
     1         .OR. JCN_IWL_SKIP.EQ.2 .OR. JCN_IWL_SKIP.EQ.-2 ) THEN 
        ICN_SIB0109_CALC_SOIL_SNOW = 1
!
      ELSEIF ( JCN_IWL_SKIP.EQ.3 .OR. JCN_IWL_SKIP.EQ.-3 ) THEN  
!
        IS = ( FSECP + 0.01 ) / RCN_DELT_SOIL
        IF ( ABS(FSECP-IS*RCN_DELT_SOIL) .LT. 0.1 ) THEN
          ICN_SIB0109_CALC_SOIL_SNOW = 1
        ELSE
          ICN_SIB0109_CALC_SOIL_SNOW = 0
        ENDIF
!
      ENDIF
!
      ICN_SIB0109_SW = ICNSW 
      ICN_SIB0109_LW = ICNIR
!
#ifdef SIB_DEBUG
      write(6,*) 'com_step_sib0109_run_stepini SW LR SS' , 
     1      ICN_SIB0109_SW , 
     1      ICN_SIB0109_LW , 
     1      ICN_SIB0109_CALC_SOIL_SNOW
#endif
!
      ICN_SIB0109_MONITOR = ICNMNTMON 
!
      SCN_SIB0109_DELT     = SCN_DELT 
!
      SCN_SIB0109_DELT_ATM = SCN_2DELTX 
!
!     SCN_SIB0109_DELT_SR  = SCNDTSW 
      SCN_SIB0109_DELT_SR  = RCN_DELT_SR 
!
      ICN_SIB0109_FIRST_STEP = ICNFST
      ICN_SIB0109_LAST_STEP  = ICNLAST
!
      end subroutine com_step_sib0109_run
!===================================================================
      END MODULE COM_STEP_SIB0109
