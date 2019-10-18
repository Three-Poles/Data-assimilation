module gswp2
!
! �O�������T�u���[�`�����X�g
!   gswp2__ini      : ������
!   gswp2__run      : �K�v�f�[�^�ݒ� 
!                     ���X�e�b�v�Ăяo�����B
!                     ���}�Ȃǂɂ��K�v�ȏ���Ԃ��B
!
! �����T�u���[�`�����X�g 
!
!   gswp2__dataread : �f�[�^�ǂݍ��� ( �����T�u���[�`�� ) 
!                     3 ���Ԃ����Ɋe���̓f�[�^�ɂ��ēǂݍ��܂��B
! 
! ���̓f�[�^���� ( 3 ���Ԃ��� ) 
!    ���������g LWDN  : 
!    ��C�䎼   QAIR  :
!    �~��       RAINF :
!    �~��       SNOWF :
!    ����       WIND  : 
!    �n�\�C��   PSURF  :
!    �ω_���~�� RAINF  :
!    �������Z�g SWDOWN :
!    ��C���x   TAIR   :
! ���̓f�[�^����  
!    ���w�_��          : ����
! ���̓f�[�^���� ( �萔 )
!    �A�����z   VEG 
!
! �o��
!
use prm, only : idim , jdim  , irad, jrad 
!
#ifdef MONYOS 
use sib_monit, only : imonit_level , imonit_select 
#endif
!
implicit none
!
integer,parameter :: idim_360 = 360
integer,parameter :: jdim_180 = 180
!
! �t�@�C���� (�L�[���[�h) 
!
character(20),save :: CKWD_LWDN = 'LWdown_srb'  ! ���������g�L�[���[�h��
character(20),save :: CKWD_SWDN = 'SWdown_srb'  ! ���������g�L�[���[�h��
character(20),save :: CKWD_TAIR = 'Tair_cru'    ! 
character(20),save :: CKWD_QAIR = 'Qair_cru'    ! 
character(20),save :: CKWD_WIND = 'Wind_ncep'   ! 
character(20),save :: CKWD_PSUR = 'PSurf_ecor'
character(20),save :: CKWD_RAIN = 'Rainf_gswp'
character(20),save :: CKWD_RAIC = 'Rainf_C_gswp'
character(20),save :: CKWD_SNOW = 'Snowf_gswp'
character(20),save :: CKWD_VEG  = 'VegClass_sib'
!
integer,save  :: ifile_lwdn = -70
integer,save  :: ifile_swdn = -71
integer,save  :: ifile_tair = -72
integer,save  :: ifile_qair = -73
integer,save  :: ifile_wind = -74
integer,save  :: ifile_psur = -75 
integer,save  :: ifile_rain = -76
integer,save  :: ifile_raic = -77
integer,save  :: ifile_snow = -78
integer,save  :: ifile_mabiki = 79
character(40) :: cfile_mabiki
integer,save  :: ifile_mask = 90
!
! �i�q�̈ܓx�o�x��� ( �P�� : �x ) 
!
real(4),save :: XLON (IDIM)    
real(4),save :: YLAT (JDIM) 
integer,save :: ILON (IDIM) 
integer,save :: JLAT (JDIM) 
!
! �i�q�̊C����� 
!
integer,save :: IMASK    (IDIM,JDIM)           ! �� 1-13 �ɏC��, �C 0
                                               ! gswp2.F90 �p�B
integer,save :: IMASK_ALL(IDIM_360,JDIM_180)   ! �� 1-16 �C 0 skip -1
                                               ! �I���W�i���ŃX�L�b�v������
                                               ! -1 �ɂ�������
!
! ���ԏ��
!
real(8),parameter   :: delt_3hour = 3*3600.D0  ! 3 ����
real(8),parameter   :: delt_1hour = 3600.D0    ! 1 ����
real(8),save        :: delt_step  =  900.D0    ! SiB ���ԍ�
real(8),save        :: delt_cosz  =  60.D0*3   ! �V���p�v�Z�ŏ��P��(sec)
!
real(8),parameter   :: cosz_min   = 0.01D0     ! cosz �����l
!
integer,save        :: istep_3hour_cosz         
integer,save        :: istep_3hour_delt
integer,save        :: istep_3hour_1hour       ! ������͒Z�g�ŕ��˂�
integer,save        :: istep_1hour_cosz
integer,save        :: istep_1hour_delt
integer,save        :: istep_delt_cosz
                                               ! �v�Z����� 
!
real(8),allocatable,save :: cosz_all (:,:,:)   ! �X�e�b�v���� cosz �̕ω�
            ! �����Ɩ�̃X�e�b�v�� 0 
            ! ����܂ރX�e�b�v�́A��(0)�ƒ��̕���
            !   (idim,jdim,0:istep_3hour_delt)
            ! �ŏI�J���� 0 �ɂ́A3���Ԑϕ��l���i�[  
!
contains 
!=====================================================
subroutine gswp2__ini ( delt_in   , idstar   ,                   &
                        imask_out , glon_out , glat_out ) 
!
use com_jobinfo_sib0109 , only : cdir_monit
!
! �E���̓t�@�C�����̐ݒ�
! �E�i�q���̐ݒ�
!
real(8),intent(in)       :: delt_in 
integer,intent(out)      :: imask_out(idim,jdim)
integer,intent(in)       :: idstar   (5) 
real(8)                  :: GLON_out (IDIM,JDIM)    
real(8)                  :: GLAT_out (IDIM,JDIM) 
!
real(4)                  :: rwork_all(idim_360,jdim_180) 
!
integer :: ILON_work (IDIM) 
integer :: JLAT_work (JDIM) 

!
integer :: icount_mask  (0:20) = 0 
integer :: i  , ii
integer :: j  
!
character(60) :: cfile_msg  
character(60) :: cfile_warn 
character(10) :: CDATE
!
namelist /nam_gswp_file/  &
      ckwd_lwdn , ckwd_swdn , ckwd_rain , ckwd_raic , ckwd_snow , & 
      ckwd_tair , ckwd_qair , ckwd_wind , ckwd_psur , ckwd_veg
!
namelist /nam_gswp_in  /  delt_cosz
!
cfile_msg  = TRIM(cdir_monit) // 'gswp2_rad_msg'
cfile_warn = TRIM(cdir_monit) // 'gswp2_rad_warn'

!
! ���̓t�@�C�����̐ݒ�
!
!read (5,nam_gswp_file) 
write(6,nam_gswp_file) 
!
! �萔�֘A 
!
!read (5,nam_gswp_in) 
write(6,nam_gswp_in) 
!
write(cdate(1:4),'(I4.4)') idstar(1)
write(cdate(5:6),'(I2.2)') idstar(2)
write(cdate(7:8),'(I2.2)') idstar(3)
write(cdate(9:10),'(I2.2)') idstar(4)
cfile_msg  = TRIM(CFILE_msg) // cdate // '.txt'
cfile_warn = TRIM(CFILE_warn) // cdate // '.txt'
open (95,file=cfile_msg)
open (96,file=cfile_warn)
!
!  ���ԍ��֘A
!
delt_step = delt_in
!
istep_3hour_1hour = delt_3hour / delt_1hour + 0.1 
istep_3hour_delt  = delt_3hour / delt_step  + 0.1 
istep_3hour_cosz  = delt_3hour / delt_cosz  + 0.1 
istep_1hour_delt  = delt_1hour / delt_step  + 0.1 
istep_1hour_cosz  = delt_1hour / delt_cosz  + 0.1 
istep_delt_cosz   = delt_step  / delt_cosz  + 0.1 
!
if ( mod ( int(delt_1hour+0.01) , int(delt_step+0.01) ) .ne. 0 ) then
  write(6,*) 'gswp2 : delt error' , delt_step 
  stop 999
endif
if ( mod ( int(delt_step+0.01) , int(delt_cosz+0.01) ) .ne. 0 ) then
  write(6,*) 'gswp2 : delt delt_cosz error' , delt_step, delt_cosz 
  stop 999
endif
!
write(6,*) 'gswp_ini : istep_3hour_cosz = ' , istep_3hour_cosz

write(6,*) 'gswp_ini : istep_3hour_1hour = ', istep_3hour_1hour
write(6,*) 'gswp_ini : istep_3hour_delt = ' , istep_3hour_delt
write(6,*) 'gswp_ini : istep_1hour_delt = ' , istep_1hour_delt
write(6,*) 'gswp_ini : istep_1hour_cosz = ' , istep_1hour_cosz
write(6,*) 'gswp_ini : istep_delt_cosz  = ' , istep_delt_cosz
!
  call gswp2_set_mabiki ( idim, jdim, &      ! In 
    ilon , xlon , jlat, ylat )               ! Out
!
  cfile_mabiki = 'IIIxJJJ'  
  write(cfile_mabiki(1:3),'(I3.3)') idim
  write(cfile_mabiki(5:7),'(I3.3)') jdim
  cfile_mabiki = 'input/mabiki' // cfile_mabiki 

  if ( idim == 360 .and. jdim == 180 ) then
    write(6,*) 'gswp2__ini: full data no mabiki'
  else

  open ( ifile_mabiki, file=cfile_mabiki , form='unformatted' )
  read(ifile_mabiki) I , J 
  if ( i .ne. idim .or. j.ne.jdim ) then
     write(6,*) 'gswp2_ini error mabikifile' , i , j , idim, jdim
       stop 999
  endif

  read(ifile_mabiki) ILON_WORK
  do i=1,idim
    if ( ilon(i) .ne. ilon_work(i) ) then
      write(6,*) 'gswp2_ini: error mabiki ilon', i, ilon(i), ilon_work(i) 
    stop 999
    endif
    enddo

    read(ifile_mabiki) JLAT_WORK
    do j=1,jdim
      if ( jlat(j) .ne. jlat_work(j) ) then
        write(6,*) 'gswp2_ini error mabiki jlat' , j , jlat(j) , jlat_work(j) 
        stop 999
      endif
   enddo

    close(ifile_mabiki) 
  endif
!
  do j=1,jdim
    glon_out(:,j) = xlon(:)
  enddo
  do i=1,idim
    glat_out(i,:) = ylat(:)
  enddo
!
!
! �}�X�N���ǂݍ���
!
  write(6,*) 'GSWP2_Input_Data/Fixed/VegClass_sib will be read' 
  open (ifile_mask, FILE =  'input/VegClass_sib' , access='direct', &
            recl=4*idim_360*jdim_180, form='unformatted')
  read(ifile_mask,rec=1) rwork_all
  close(ifile_mask) 
!
!  orginal mask check 
!
  imask_all(:,:) = -1 
  do j=1,jdim_180
  do i=1,idim_360
    imask_all(i,j) = rwork_all(i,j)+0.1
    if ( imask_all(i,j) >= 0 .and. imask_all(i,j) <= 20 ) then
      icount_mask(imask_all(i,j)) = icount_mask(imask_all(i,j)) + 1 
    else 
      write(6,*) 'gswp2_ini error imask i j ' , imask_all(i,j) , i , j 
    endif   
  enddo
  enddo
!
  write(6,*) 'Number of mask' 
  do i=0,20
    write(6,*) i , icount_mask(i)
  enddo
!
  imask_all(:,:) = -1 
  do j=1,jdim
  do i=1,idim
    imask_all(ilon(i),jlat(j)) = rwork_all(ilon(i),jlat(j))+0.1
  enddo
  enddo
!
#ifdef SIB_DEBUG
  write(6,*) 'imask_all' , imask_all
#endif
!
  write(6,*) 'mask check start'
  imask(:,:) = 0
  do j=1,jdim  
  do i=1,idim  
    if ( rwork_all(ilon(i),jlat(j)) .gt. 0.5 ) then
      imask(i,j) = rwork_all(ilon(i),jlat(j))+0.1
    endif
    if ( rwork_all(ilon(i),jlat(j)) .gt. 16.5 ) then
      write(6,*) 'ERROR gswp2__ini too large Veg, maybe endian problem.' ,&
                  rwork_all(ilon(i),jlat(j))
      stop 999
!
    endif
    if ( j.gt. 150.5 .and. rwork_all(i,j) .gt. 0.5 ) then 
      write(6,*) 'gswp2__ini maskcheck warning ' , i , j , rwork_all(i,j)
    endif 
  enddo
  enddo
  write(6,*) 'mask check end'
!
! �}�X�N�̏C��
!
  icount_mask  (:) = 0 
!
  call gswp2_imask_mod ( idim , jdim , -1 , &
                         imask )             ! inout
!
  imask_out(:,:) = imask(:,:) 
!
!  allocate 
!
  allocate ( cosz_all (idim,jdim,0:istep_3hour_delt ) )
!
end subroutine gswp2__ini
!=====================================================
subroutine gswp2__run      (          & 
    IDATE       , RDAY   , RSEC   ,                 & ! In   �������
    zmean_1hr_day , ztemp_step    , daytime_1hr   ,  & ! Out
    RVISB , RVISD , RNIRB , RNIRD ,                 & 
    data_lwdn_out ,                                 & 
    data_rail_out , data_raic_out ,                 & 
    data_tair_out , data_qair_out ,                 &
    data_psur_out , data_pdel_out , data_pful_out , &
    data_wind_out  )
!
use calendar, only : calendar_run_getkt , calendar_run_getid
!
! ���� ( ���Ԋ֌W ) 
!
integer,intent(in)  :: idate     (5) 
real(8),intent(in)  :: rday                 ! ��N�̒��ł̈ʒu
                                            ! 1/1-12/31 �� 0-1 �ɑΉ�
real(8),intent(in)  :: rsec                 ! ����̒��ł̑��Έʒu 0-1 
!
! �o��
!
real(8),intent(out) :: data_lwdn_out (idim,jdim) 
real(8),intent(out) :: data_rail_out (idim,jdim) 
real(8),intent(out) :: data_raic_out (idim,jdim) 
real(8),intent(out) :: data_tair_out (idim,jdim) 
real(8),intent(out) :: data_qair_out (idim,jdim) 
real(8),intent(out) :: data_psur_out (idim,jdim) 
real(8),intent(out) :: data_pdel_out (idim,jdim) 
real(8),intent(out) :: data_pful_out (idim,jdim) 
real(8),intent(out) :: data_wind_out (idim,jdim) 
!
real(8),intent(inout) :: zmean_1hr_day   (idim,jdim) ! ztemp ���]��
real(8),intent(out)   :: ztemp_step      (idim,jdim) 
real(8),intent(inout) :: daytime_1hr     (idim,jdim) 
!
real(8),intent(inout) :: rvisb         (irad,jrad) 
real(8),intent(inout) :: rvisd         (irad,jrad) 
real(8),intent(inout) :: rnirb         (irad,jrad) 
real(8),intent(inout) :: rnird         (irad,jrad) 
!
real(8)             :: data_snow_out_dummy (idim,jdim) 
!
real(4),save        :: data_lwdn     (idim,jdim) 
real(4),save        :: data_swdn     (idim,jdim)  
real(4),save        :: data_rain     (idim,jdim) 
real(4),save        :: data_raic     (idim,jdim) 
real(4),save        :: data_snow     (idim,jdim) 
real(4),save        :: data_tair_pre (idim,jdim) 
real(4),save        :: data_tair_ftr (idim,jdim) 
real(4),save        :: data_qair_pre (idim,jdim) 
real(4),save        :: data_qair_ftr (idim,jdim) 
real(4),save        :: data_psur_pre (idim,jdim) 
real(4),save        :: data_psur_ftr (idim,jdim) 
real(4),save        :: data_wind_pre (idim,jdim) 
real(4),save        :: data_wind_ftr (idim,jdim) 
real(8)             :: data_tmp(idim,jdim)
!
! ���[�N  ( ������ delt=900 �� 1 ���� 4 �X�e�b�v�̏ꍇ ) 
!
real(8),parameter   :: zero = 0.D0 
integer             :: i,j
integer,save        :: ihour        ! 3 ���Ԓ��̎��ԃt���O    (1,2,3)
integer,save        :: istep        ! 3 ���Ԓ��̃X�e�b�v�t���O(1,2,...,12)
!
integer             :: isec         ! ��ƕϐ� ( 3 ���Ԓ��̒��̈ʒu )
real(8)             :: wgt_next     ! �����X�e�b�v�̎��ԏd��
integer             :: is           ! �X�e�b�v�J�E���^ (DO LOOP �p)
integer             :: kt
!
! �Z�g�]���E�␳�֘A
!
real(8),parameter   :: SOLAR_CONST = 1360.D0 
!
! �E�O���Ԃ��Ƃ̍��
!
!   �X�e�b�v�� ( delt_cosz ���[�v ) 
real(8) :: cos_sunangle     (idim,jdim)  ! �e delt_cosz �ł� cosz 
real(8) :: cos_sunangle_sum (idim,jdim)  ! cos_sunangle �̎��Ԑϕ�
integer :: icount_sum       (idim,jdim)  ! ���� delt_cosz �̐�   
real(8) :: rs                            ! day �̂Ȃ��ł̑��Έʒu 0-1 
integer :: it                            ! DO LOOP �p�J�E���^
!
!   ���_�l�]��
!
real(8) :: swdn_theo  (idim,jdim) 
!
! �E �ꎞ�Ԃ��Ƃ̍��
!
real(8) :: cosz_sum         (idim,jdim)


real(8),save :: swdn_1hr_day     (idim,jdim) 
!
integer             :: iflag_step 
logical,save        :: lfirst = .true.  
integer             :: idate0(5) 
integer             :: irec 
real(8)             :: swdn_step       (idim,jdim) 
!
!
#ifdef MONYOS
character(7) :: CMARK 
real(8),parameter :: one = 1.D0
#endif
!
! --------------------------------
! > ���ԃt���O iflag_step �̐ݒ� <
! --------------------------------
!   3 ���Ԑ��� : 1 
!   1 ���Ԑ��� : 2 
!   ����ȊO   : 3
!
  if     ( mod ( int(rsec*86400+0.01) , 3*3600 ) == 0 ) then
    iflag_step = 1
  elseif ( mod ( int(rsec*86400+0.01) ,   3600 ) == 0 ) then
    iflag_step = 2 
  else
    iflag_step = 3
  endif
!
! ���̂Ƃ���... 1 �̂ݑΉ�
!
!  if ( iflag_step.gt. 2 ) then
!    write(6,*) 'gswp2__run error : iflag_step ' , iflag_step , rsec, idate
!    stop 999
!  endif
!
! ================================
! > 3 ���Ԃ� 1 �x�̏��� �������� <
! ================================
!   �t���b�N�X��(�J2��E��A�Z�g�A���g) �̓Z�[�u����B
!     ���ɒZ�g�͓V���p�␳������̂Œ��ӁB
!   �u�Ԓl(�C���A�䎼�A�C���A��) �́A
!     ���Y�����f�[�^(���̒l�Ƃ��ēǂݍ��݂���) ���ߋ��̒l�z��ɃR�s�[�B
!     ���̎����f�[�^�𖢗��̒l�Ƃ��ēǂݍ���
!
if ( iflag_step <= 1 ) then
!
! --------------------
! > �f�[�^�̓ǂݍ��� < 
! --------------------
!
!  call CALENDAR_RUN_GETID ( IDATE   , IDATE_FTR , 3 )
!
! �u�Ԓl
!
  Idate0 (1) = idate (1) 
  if ( idate(1)<=1982 .or. idate(1)>=1996 ) then
    write(6,*) 'gswp2_run error iyear = ' , idate 
    stop 999 
  else 
    Idate0 (2:3) = 1 
    Idate0 (4:5) = 0 
  endif
  call calendar_run_getkt ( idate0 , idate , 4 , kt  ) 
  irec = kt / 3 + 1 
  write(6,*) 'gswp2  kt = ' , kt 
!
  if ( lfirst ) then 
    lfirst =.false. 
    call gswp2__dataread ( ifile_tair, CKWD_TAIR , data_tair_ftr , idate(1) , irec )
    call gswp2__dataread ( ifile_qair, CKWD_QAIR , data_qair_ftr , idate(1) , irec )
    call gswp2__dataread ( ifile_psur, CKWD_PSUR , data_psur_ftr , idate(1) , irec )
    call gswp2__dataread ( ifile_wind, CKWD_WIND , data_wind_ftr , idate(1) , irec )
  endif
!
  data_tair_pre  (:,:) =   data_tair_ftr  (:,:) 
  data_qair_pre  (:,:) =   data_qair_ftr  (:,:) 
  data_psur_pre  (:,:) =   data_psur_ftr  (:,:) 
  data_wind_pre  (:,:) =   data_wind_ftr  (:,:) 
!
  call gswp2__dataread ( ifile_tair, CKWD_TAIR , data_tair_ftr , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_qair, CKWD_QAIR , data_qair_ftr , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_psur, CKWD_PSUR , data_psur_ftr , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_wind, CKWD_WIND , data_wind_ftr , idate(1) , irec+1 )
!
! �t���b�N�X
!
  call gswp2__dataread ( ifile_swdn, CKWD_SWDN , data_swdn , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_lwdn, CKWD_LWDN , data_lwdn , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_rain, CKWD_RAIN , data_rain , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_raic, CKWD_RAIC , data_raic , idate(1) , irec+1 )
  call gswp2__dataread ( ifile_snow, CKWD_SNOW , data_snow , idate(1) , irec+1 )
!
#ifdef MONYOS
! ���j�^ �` �Z�g�C���O
  CMARK = 'FSRORG' 
  data_tmp(:,:) = data_swdn(:,:)  
  CALL MONIT_ADD_2 ( CMARK , data_tmp , 1 , delt_3hour , ONE )     
#endif
!
! ------------------------------
! > �O���Ԃ̊Ԃ� �V���p�̕ω�  < 
! ------------------------------
!
  cosz_all(:,:,:)=0 
  do is=1,istep_3hour_delt             ! �X�e�b�v
    cos_sunangle_sum(:,:)=0 
    icount_sum      (:,:)=0 
!
    do it=1,istep_delt_cosz            ! �X�e�b�v��
!
      rs = ( idate(4) * 3600.D0 + ((is-1)*istep_delt_cosz+it-0.5)*delt_cosz) &
           / 3600.D0 / 24           ! day �̂Ȃ��ł̈ʒu (0-1) 
      call GSWP2_SUNANG ( RDAY   , RS    ,  XLON     , YLAT    , &
                          cos_sunangle    )                         ! Out
!
      do j=1,jdim 
      do i=1,idim 
        if ( imask(i,j) .gt.0 .and. cos_sunangle(i,j) .gt. cosz_min ) then 
          cos_sunangle_sum(i,j) = cos_sunangle_sum(i,j) &
                                + cos_sunangle(i,j) * delt_cosz
          icount_sum  (i,j) = icount_sum  (i,j) + 1   
        endif
      enddo
      enddo
    enddo
!
!   �X�e�b�v�ł̓V���p�̌v�Z ( ����܂ޕ��ϒl ) 
!       cosz_all  
!
    do j=1,jdim 
    do i=1,idim 
      if ( icount_sum(i,j) >= 1 ) then    
        cosz_all(i,j,is) = cos_sunangle_sum(i,j) / delt_step 
      endif 
      if ( cosz_all(i,j,is) .lt. cosz_min ) then
        cosz_all(i,j,is) = 0
        cos_sunangle_sum(i,j) = 0      ! ���̌�Ŏg���͂��Ȃ�
        icount_sum      (i,j) = 0      ! ���̌�Ŏg���͂��Ȃ�
      endif
    enddo
    enddo 
  enddo   
!
! -----------------------------------------------------
! > ���_�̒Z�g�t���b�N�X�����p�����A���˒Z�g�� QC  < 
! -----------------------------------------------------
! 
!    swdn_theo_all(:,:) : ���镽�ς������_�l ( = ��� ) 
!
  cosz_all(:,:,0) = 0. 
  do is=1,istep_3hour_delt             ! �S�X�e�b�v����������
    cosz_all(:,:,0) = cosz_all(:,:,0) + cosz_all(:,:,is) * delt_step 
  enddo
  swdn_theo(:,:) = cosz_all(:,:,0) / delt_3hour * SOLAR_CONST 
!
!    ���_�̒Z�g�t���b�N�X��� ���z���Ă�����Adata_swdn �����炷 
!
  do j=1,jdim
  do i=1,idim
    if ( imask(i,j) .le.0 ) then
      data_swdn(i,j) = 0. 
    endif
  enddo
  enddo
!
!    �`�F�b�N�̂��߂̃��[�v��������
!
  do j=1,jdim
  do i=1,idim
    if ( imask(i,j) .gt.0 ) then
!
!!      r4work   (i,j) = data_swdn   (i,j)     ! �����O
!!      r4work2  (i,j) = swdn_theo   (i,j)     ! �����O
!
!   �y���C��
!
!     ���_�̒Z�g���˂� 1 �ȉ��ŁA�Z�g�t���b�N�X�� 1W/m**2 �ȉ��Ȃ�
!     �����Ƃ���ɂ���
!
      data_swdn(i,j) = max(data_swdn(i,j),0.d0)      ! ���͏���   
!
      if     (       data_swdn(i,j) .le. 1         & ! ���˂Ȃ�
               .and. swdn_theo(i,j) .lt. 1. ) then   ! ��
        swdn_theo   (i,j) = 0.
        data_swdn   (i,j) = 0.
      endif
!
!   �`�F�b�N ( �x�� ) 
!
#ifdef SIB_DEBUG
!    �f�[�^�����_�� 1 ���ȉ�
      if     (       data_swdn(i,j) .gt. 1.D-10 &
               .and. data_swdn(i,j) .le. swdn_theo(i,j)*0.1 ) then
         write(95,10) 'gswp2: XXXX too small ' , idate(1:4), &
                 i , j , xlon(i) , ylat(j) , &
                 data_swdn(i,j) , swdn_theo(i,j)
      endif
!
!    �f�[�^�����_�� 1.2 ���ȏ�
      if     (       data_swdn(i,j) .gt. 1.D-10                       &
             .and. data_swdn(i,j) .gt. swdn_theo(i,j)*1.2 ) then
        write(95,10) 'gswp2: XXXX too large ' , idate(1:4) , &
                 i , j , xlon(i) , ylat(j) ,   &
                 data_swdn(i,j) , swdn_theo(i,j)
      endif
!
!   �`�F�b�N ( �����x�� ) 
!    �f�[�^�����_�� 1 ���ȉ��ŁA���f�[�^�� 5W/m**2 �ȏ�
      if     (       data_swdn(i,j) .gt. 1.D-10              &
               .and. data_swdn(i,j) .le. swdn_theo(i,j)*0.1  & 
               .and. data_swdn(i,j) .gt. 5                   & 
             ) then
        write(96,10) 'gswp2 : XXXX too small ' , idate(1:4) , &
                 i , j , xlon(i) , ylat(j) ,   &
                 data_swdn(i,j) , swdn_theo(i,j)
      endif
!
!    �f�[�^�����_�� 40 ���ȏ�ŁA���f�[�^�� 10W/m**2 �ȏ�
      if     (       data_swdn(i,j) .gt. 1.D-10              &
               .and. data_swdn(i,j) .gt. swdn_theo(i,j)*4    &
               .and. swdn_theo(i,j) .gt. 10                  &
              ) then
        write(96,10) 'gswp2: XXXX too large ' , idate(1:4) , &
                 i , j , xlon(i) , ylat(j) ,   &
                 data_swdn(i,j) , swdn_theo(i,j)
      endif
!
!    �f�[�^�����_�� 20 ���ȏ�ŁA���f�[�^�� 20W/m**2 �ȏ�
      if     (       data_swdn(i,j) .gt. 1.D-10              &
               .and. data_swdn(i,j) .gt. swdn_theo(i,j)*2    &
               .and. swdn_theo(i,j) .gt. 20                  &
              ) then
        write(96,10) 'gswp2: XXXX too large ' , idate(1:4) , &
                 i , j , xlon(i) , ylat(j) ,   &
                 data_swdn(i,j) , swdn_theo(i,j)
      endif
#endif
!
 10 format (A, 1X , I4, 1X, I2 , 1X , I2, 1X , I2 , 1X , I3 , 1X , I3 , 1X , &
               F7.2 , 1X , F7.2 , 1X , &
               F7.2 , 1X , F7.2 )
 11 format (A, 1X , I4, 1X, I2 , 1X , I2, 1X , I2 , 1X , I3 , 1X , I3 , &
               '  from '  ,   F7.2 , '  to '  , F7.2 ) 
!
!    �C��
!     ���_�̕�����������΁A���_�ɂ���B
!
      if     ( data_swdn(i,j) .gt. swdn_theo(i,j) ) then
        write(96,11) 'gswp2: XXXX corrected ' , idate(1:4) , &
                     i , j ,  data_swdn(i,j) ,  swdn_theo(i,j)
        data_swdn(i,j) = swdn_theo(i,j) 
      endif
    endif
  enddo
  enddo
!
  ihour = 0 
  istep = 0 
!
endif
!
! --------------------------------------------------------------
! > �����܂łɓ����Ă�����́A�쐬����K�v�̂�����̂̂܂Ƃ� < 
! --------------------------------------------------------------
! �����܂łɓ����Ă������
!  �E�S�X�e�b�v�ł� (����܂߂����ς�) cosz          : cosz_all (:,:,it) 
!         delt �Ԃ̕��ρB���Ԃ͂������Ă��Ȃ�
!  �E��L 3 ���Ԑϕ��l                               : cosz_all (:,:,0) 
!         ���Ԃ��������Ă���
!  �E����܂߂� 3 ���Ԃ̕��ς̒Z�g (�␳�������͒l)  : data_swdn 
! 1 ���Ԃ��Ƃɗ~��������
!  �E���X�e�b�v�݂̂� 1 ���ԕ��ς̒Z�g               : swdn_1hr_day  
!       cosz_all �����ƂɁA
!         data_swdn x 3 ����                            ! �S�G�l���M�[
!         x ( cosz �̎��Ԑϕ� / (cosz_all �̎��Ԑϕ� )  ! ���A1 ���Ԃł̊���
!         / ���̎���                         
!  �E���X�e�b�v�݂̂� 1 ���ԕ��� RVISB �� 
!       swdn_1hr_day ����v�Z
!  �E���X�e�b�v�݂̂� 1 ���ԕ��ς� cosz              : zmean_1hr_day  
!       cosz_all �����ƂɁA���Y�������݂̂𕽋ς���
! �e�X�e�b�v�ŗ~��������
!  �Ecosz                                            : ztemp_step 
!       = cosz_all ���̂��� 
!
! ===========================
! > �Z�g�� 1 ���Ԃ��Ƃ̏��� < 
! ===========================
!  
! 
!
if ( iflag_step <= 2 ) then
  ihour = ihour + 1 
!
! cosz_sum : cosz_all �̎��Ԑϕ� ( 4 �� )         
! daytime_1hr  : ���̎���            ( 4 �� ) ; 0 - 3600 
!
  cosz_sum(:,:) = 0   
  daytime_1hr (:,:) = 0   
  do is=1,istep_1hour_delt 
    do j=1,jdim 
    do i=1,idim 
      if ( cosz_all(i,j,(ihour-1)*istep_1hour_delt+is) .gt. 0 ) then
        cosz_sum(i,j) = cosz_sum(i,j)                            &
                + cosz_all(i,j,(ihour-1)*istep_1hour_delt+is) * delt_step 
        daytime_1hr(i,j) = daytime_1hr(i,j) + delt_step 
      endif
    enddo
    enddo
  enddo   
!
! ���̃X�e�b�v�����ŕ��ς����A�Z�g�� cosz 
!
  do j=1,jdim 
  do i=1,idim 
    if ( daytime_1hr(i,j) .gt. 0 .and. cosz_all(i,j,0) .gt. 0) then
      swdn_1hr_day (i,j) &
            = (data_swdn(i,j) * delt_3hour)            & ! �SE 
               * cosz_sum(i,j) / cosz_all(i,j,0)       & ! ���A���ꎞ��
               / daytime_1hr(i,j)                        ! ���̒��̎��ԂŊ���
      zmean_1hr_day(i,j) = cosz_sum(i,j) / daytime_1hr(i,j)   
    else 
      swdn_1hr_day (i,j) = 0. 
      zmean_1hr_day(i,j) = 0. 
    endif
  enddo
  enddo
!
!  RVISB ���̕]�� ( 
!
  CALL GSWP2_SWDN_1HR_DEVIDE (                     &  
      RVISB , RVISD , RNIRB , RNIRD ,              &  ! Out
      swdn_1hr_day  , zmean_1hr_day   )               ! In 
!
endif
!
! ===========================
! > �Z�g�̖��X�e�b�v�̏��� < 
! ===========================
!
istep = istep + 1 
!
ztemp_step (:,:) = cosz_all(:,:,istep) 
!
  swdn_step  (:,:) = 0. 
  do j=1,jdim
  do i=1,idim
    if ( imask(i,j) >= 1 .and. zmean_1hr_day(i,j) > cosz_min/10 ) then
      swdn_step  (i,j) = swdn_1hr_day(i,j)                       & 
                         * ztemp_step(i,j) / zmean_1hr_day(i,j)
    endif
  enddo
  enddo
!
! ===============================
! > ���˂̎��ԓ��}���� �������� <
! ===============================
!   ���˂̏ꍇ�́A
!     ��C���f������ 1 ���Ԃ� 1 �x�����v�Z���Ȃ��ꍇ
!     �S�^�C���X�e�b�v�Ōv�Z����ꍇ
!   ������B
!
! --------
! > ���g <  ( �P�� W/m**2 ) 
! --------
!
! �Ƃ肠�������}�����ŐH�킹��B
!
data_lwdn_out (:,:) = data_lwdn (:,:) 
!
! ==================================
! > �t���b�N�X�̎��ԓ��}������������ <
! ==================================
!   �t���b�N�X(�J�E��) 
!
! ------------
! > �J(�ω_) <   
! ------------
!  �����ɂ��ΒP�� kg/m**2/s �Ƃ���B  
!  �f�[�^�͗���̂݁B�C��ɂ� 0 �������Ă���B
!  �P�ʂ͗v�����B
!     1984 ave, *86400 ; contour = 0 to 11 = 11*365 ~ 4000mm/yr 
!  
!
data_raic_out (:,:) = data_raic (:,:) 
!
! ------------
! > �J(�w�_) <
! ------------
!
data_rail_out (:,:) = data_rain (:,:) - data_raic (:,:) 
!
! �`�F�b�N ( ��K�͋Ì��ŕ��͂Ȃ��� ) 
!
#ifdef SIB_DEBUG
do j=1,jdim
do i=1,idim
  if ( imask(i,j) .gt.0 ) then
    if ( data_rail_out(i,j) <= -1.D-10 ) then
      write(95,*) 'gswp2__run rain large le 0' , i , j , data_rail_out(i,j) , data_rain(i,j) , data_raic(i,j) 
    endif
    if ( data_rail_out(i,j) <= -1.D-2 ) then
      write(96,*) 'gswp2__run rain large le 0' , i , j , data_rail_out(i,j) , data_rain(i,j) , data_raic(i,j) 
    endif
  endif
enddo
enddo
#endif

data_rail_out (:,:) = max ( data_rail_out (:,:) , zero )
!
! ------
! > �� <
! ------
!
data_snow_out_dummy (:,:) = max ( data_snow (:,:) , zero ) 
!
! ------------------
! > for LAND model <
! ------------------
!
data_raic_out (:,:) = data_raic_out (:,:) * delt_step 
data_rail_out (:,:) = (data_rail_out (:,:) + data_snow_out_dummy(:,:)) &
                                          * delt_step 
!
! ==================================
! > �u�Ԓl�̎��ԓ��}������������ <
! ==================================
!
ISEC = rsec*86400 + delt_step/2 + 0.00001    ! middle 
ISEC = MOD ( ISEC , 3*3600 )      ! 
WGT_NEXT = ISEC / 3600.D0 / 3     
!
! --------
! > ���x <
! --------
!
call gswp2_timeinterp ( data_tair_pre , data_tair_ftr , wgt_next ,  &
                        data_tair_out )   
!
! --------
! > �䎼 <
! --------
!
call gswp2_timeinterp ( data_qair_pre , data_qair_ftr , wgt_next ,  &
                        data_qair_out )   
!
! --------
! > ���� <
! --------
!
call gswp2_timeinterp ( data_wind_pre , data_wind_ftr , wgt_next ,  &
                        data_wind_out )   
!
! ------------
! > �n��C�� <
! ------------
!
call gswp2_timeinterp ( data_psur_pre , data_psur_ftr , wgt_next ,  &
                        data_psur_out )   
data_psur_out(:,:) = data_psur_out(:,:) / 100 
!
data_pdel_out(:,:) = 10. 
data_pful_out(:,:) = data_psur_out(:,:) - data_pdel_out(:,:) / 2 
!
! ==============
! >> �`�F�b�N <<
! ==============
!    3 ���Ԓl�ƕ��ς������Ă��Đ������Ƃ�Ă��邩�ǂ����`�F�b�N����B
!      1 �Z�g�A
!      2 ���g
!      3 
!
! ���j�^
!
#ifdef MONYOS
IF ( IMONIT_LEVEL .GE. IMONIT_SELECT ) THEN
!
! �S�Z�g
    CMARK = 'FSR' 
    CALL MONIT_ADD_2 ( CMARK , SWDN_STEP , 1, DELT_step , ONE )     
!
! ���g
    CMARK = 'FLR' 
    CALL MONIT_ADD_2 ( CMARK , data_lwdn_out , 1, DELT_step , ONE )
!
! �_��
!   CMARK = 'FCLD'
!   CALL MONIT_ADD_2 ( CMARK , cld , 1, DELT_step , ONE )
!
! ���x
    CMARK = 'FTMP' 
    CALL MONIT_ADD_2 ( CMARK , data_tair_out, 1, DELT_step , ONE )
!
! �䎼
    CMARK = 'FQ' 
    CALL MONIT_ADD_2 ( CMARK , data_qair_out , 1, DELT_step , ONE )
!
! �n�\�ʋC��
    CMARK = 'FPS' 
    CALL MONIT_ADD_2 ( CMARK , data_psur_out , 1, DELT_step , ONE )
!
! �ω_���~��
    CMARK = 'FPC' 
    CALL MONIT_ADD_2 ( CMARK , data_raic_out , 1, ONE , ONE )
!
! ��K�͋Ì����~��
    CMARK = 'FPL' 
    CALL MONIT_ADD_2 ( CMARK , data_rail_out , 1, ONE , ONE )
!
! ����
    CMARK = 'FU' 
    CALL MONIT_ADD_2 ( CMARK , data_wind_out , 1, DELT_step , ONE )
!
! ����
    CMARK = 'FZMEAN' 
    CALL MONIT_ADD_2 ( CMARK , zmean_1hr_day , 1, DELT_step , ONE )
!
! ����
    CMARK = 'FZTEMP' 
    CALL MONIT_ADD_2 ( CMARK , ztemp_step , 1, DELT_step , ONE )
ENDIF
#endif
!
end subroutine gswp2__run 
!=======================================================
subroutine check ( rsave , idim , jdim , istep_3hour_delt , ielem , r8 ) 
integer,intent(in) :: idim 
integer,intent(in) :: jdim 
integer,intent(in) :: istep_3hour_delt
integer,intent(in) :: ielem
real(8) ,intent(in) :: rsave ( idim,jdim,istep_3hour_delt,ielem)  
real(8) ,intent(in) :: r8    ( idim,jdim)
integer :: i
integer :: j
real(8) :: r1 (idim,jdim)
!
r1(:,:) = 0. 
!
write(6,*) 'check: ', istep_3hour_delt
do i=1,istep_3hour_delt
  r1(:,:) = r1(:,:) + rsave(:,:,i,ielem)  ! sum 
enddo
!
do j=1,jdim  
do i=1,idim  
  if ( abs(r1(i,j) - r8(i,j)*istep_3hour_delt ) .gt. 1.D-3 ) then
    write(6,*) 'check diff' , ielem , i,j,r1(i,j),r8(i,j), &
                rsave(i,j,1:istep_3hour_delt,ielem) 
  endif
enddo
enddo
!
end subroutine check 
!======================================================
subroutine gswp2__dataread ( ifile , CKWD , data_out4 , iyear , irec )
!
  integer,intent(inout)   :: ifile
  real(4),intent(out)     :: data_out4 (idim,jdim)
  character(20),intent(in):: CKWD  
  real(4)                 :: rwork_all (idim_360,jdim_180) 
  integer,intent(in)      :: irec
  integer,intent(in)      :: iyear
  character(70)           :: cfile_1
  character(70)           :: cfile_2
  character(4)            :: cyear 
!
  integer :: irecx 
!
  integer :: i,j 
!
! �t�@�C���I�[�v��
!
  if ( ifile .lt. 0 ) then
    ifile = - ifile 
    write(cyear,'(I4.4)') iyear 
    CFILE_2 = 'input/' // TRIM(CKWD) // '_' // CYEAR 
    cfile_1 = 'IIIxJJJ'
    write(cfile_1(1:3),'(I3.3)') idim
    write(cfile_1(5:7),'(I3.3)') jdim
    cfile_1 = 'input/' // TRIM(CKWD) // '_' // TRIM(cfile_1) // '_' // CYEAR 
!
    if ( idim == 360 .and. jdim == 180 ) cfile_1 = cfile_2
!
    write(6,*) 'gswp2_dataread try to open' , ifile , cfile_1 
!    open ( ifile , file=cfile_1 , form='unformatted' , access='direct' , &
!           recl = 4*idim*jdim , action='read' , status='old' , err=20 )
    open ( ifile , file=cfile_1 , form='binary' , access='direct' , &
           recl = 4*idim*jdim , action='read' , status='old' , err=20 )
    write(6,*) 'gswp2_dataread' , ifile , cfile_1 , ' is opened.'
    goto 10
!
20 continue
    ifile = ifile - 20     
    write(6,*) 'gswp2_dataread try to open' , ifile , cfile_2 
!    open ( ifile , file=cfile_2 , form='unformatted' , access='direct' , &
!    recl = 4*idim_360*jdim_180 , action='read' , status='old' , err=30 )
    open ( ifile , file=cfile_2 , form='binary' , access='direct' , &
    recl = 4*idim_360*jdim_180 , action='read' , status='old' , err=30 )
    write(6,*) 'gswp2_dataread' , ifile , cfile_2 , ' is opened.'
    goto 10
!
30 continue
   write(6,*) 'gswp2_dataread error, ifile =' , ifile , iyear , ckwd  
   stop 1 
!
10 continue
  endif
!
  irecx = irec   
!
!Simple Biosphere (SiB) Model
!
! 1  Evergreen Broadleaf Trees
! 2  Broadleaf Deciduous Trees
! 3  Deciduous and Evergreen Trees
! 4  Evergreen Needleleaf Trees
! 5  Deciduous Needleleaf Trees
! 6  Ground Cover with Trees and Shrubs
! 7  Groundcover Only
! 8  Broadleaf Shrubs with Perennial Ground Cover
! 9  Broadleaf Shrubs with Bare  Soil
!A10 Groundcover with Dwarf Trees and Shrubs
!B11 Bare Soil
!C12 Agriculture or C3 Grassland  to  7
!D13 Persistent Wetland           to 10 
!E14 Water                        to  0 
!F15 Ice Cap and Glacier          to 13
!G16 Missing                      to  0
!
  if ( ifile.ge.70 ) then
    read(ifile,rec=irecx) data_out4
  else 
    read(ifile,rec=irecx) rwork_all
    do j=1,jdim
    do i=1,idim
      data_out4(i,j) = rwork_all(ilon(i),jlat(j))
    enddo
    enddo
  endif
!
end subroutine gswp2__dataread
!======================================================
subroutine gswp2_timeinterp (                  &
         data_pre , data_next , wgt_next ,     &   ! In
         data_out )                                ! out
!
use prm , only :    idim , jdim
!
implicit none 
!
real(4),intent(in)   :: data_pre (idim*jdim)
real(4),intent(in)   :: data_next(idim*jdim)
real(8),intent(in)   :: wgt_next
!
real(8),intent(out)  :: data_out (idim*jdim)
!
integer :: ij 
!
do ij=1,idim*jdim
  data_out(ij) =   (1-wgt_next) * data_pre  (ij)       &
                 +   wgt_next   * data_next (ij)
enddo
!
end subroutine gswp2_timeinterp
!======================================================
subroutine  gswp2_SWDN_1HR_DEVIDE (               &
     RVISB , RVISD , RNIRB , RNIRD ,         & ! Out 
     rshrt , zmean   )          ! In 
!
USE PRM , ONLY : idim,jdim,irad,jrad
!
real(8),intent(in) :: rshrt(idim*jdim)
real(8),intent(in) :: zmean(idim*jdim)
!
real(8),intent(out) :: rvisb(irad*jrad)  
real(8),intent(out) :: rvisd(irad*jrad)
real(8),intent(out) :: rnirb(irad*jrad)
real(8),intent(out) :: rnird(irad*jrad)
!
REAL(8),PARAMETER :: ZERO = 0.D0
REAL(8),PARAMETER :: ONE  = 1.D0
REAL(8),PARAMETER :: D001 = 1.D-2
integer           :: i 
real(8),parameter :: cld = 0.5 
real(8)           :: dif_rat 
real(8)           :: vn_rat 
!
LOGICAL,SAVE  :: LFIRST = .true. 
!
IF ( LFIRST ) THEN
  LFIRST = .FALSE.
  WRITE(6,*) 'gswp2_swdn_1hr_devide' 
  IF ( IDIM .NE. IRAD .OR. JDIM.NE.JRAD ) THEN
    WRITE(6,*) 'gswp2 error ' , IDIM , IRAD , JDIM , JRAD 
    STOP 999
  ENDIF
ENDIF
! 
DO I=1,IDIM*JDIM
!----------------------------------------------------------------------
!     DOWNWELLING SHORTWAVE RADIATION COMPONENTS : GOUDRIAAN ( 1977)
!----------------------------------------------------------------------
  DIF_RAT = 0.0604D0 / MAX ( D001 , ZMEAN(I)-0.0223 ) + 0.0683D0
  DIF_RAT = MAX( DIF_RAT , ZERO )
  DIF_RAT = MIN( DIF_RAT , ONE  )
!
  DIF_RAT = DIF_RAT + ( 1. - DIF_RAT ) * CLD 
  VN_RAT  = (  580. - CLD *464. ) / ( (580. - CLD*499. ) &
            + ( 580. - CLD*464. ) )
!
  RVISB(I) = (1.-DIF_RAT) * VN_RAT      * RSHRT(I)
  RVISD(I) = DIF_RAT      * VN_RAT      * RSHRT(I)
  RNIRB(I) = (1.-DIF_RAT) * (1.-VN_RAT) * RSHRT(I)
  RNIRD(I) = DIF_RAT      * (1.-VN_RAT) * RSHRT(I)
ENDDO
!
end subroutine gswp2_swdn_1hr_devide
!
!======================================================
SUBROUTINE gswp2_monit_regist_forcings 
#ifdef MONYOS
!
! ISLSCP_MAIN �ŏo�͂���ϐ����X�g
!
use sib_monit, only : imonit_level , imonit_select 
!
CHARACTER( 7)  :: CMARK 
CHARACTER(32)  :: CTITLE 
CHARACTER(13)  :: CUNIT
!
LOGICAL,SAVE ::  LFIRST = .TRUE.
!
IF ( LFIRST ) THEN
  WRITE(6,*) 'GSWP2_MONIT_REGIST_FORCINGS M.Hosaka'
  LFIRST = .FALSE. 
ELSE
  WRITE(6,*) 'GSWP2_MONIT_REGIST_FORCINGS error'
  stop 999
ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_SELECT ) THEN
!
      CMARK  = 'FSR'
      CTITLE = 'SHORT RADIATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FSRORG'
      CTITLE = 'SHORT RADIATION (ATMOSPHERIC FORCING) ORG'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FRVISB'
      CTITLE = 'RVISB (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FRVISD'
      CTITLE = 'RVISD (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FRNIRB'
      CTITLE = 'RNIRB (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FRNIRD'
      CTITLE = 'RNIRD (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FZMEAN'
      CTITLE = 'ZMEAN (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FZTEMP'
      CTITLE = 'ZTEMP (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FLR'
      CTITLE = 'LONG RADIATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FTMP'
      CTITLE = 'TEMPERATURE (ATMOSPHERIC FORCING)'
      CUNIT  = 'K'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FQ'
      CTITLE = 'HUMIDITY (ATMOSPHERIC FORCING)'
      CUNIT  = ''
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FPS'
      CTITLE = 'SURFACE PRESSURE (ATMOSPHERIC FORCING)'
      CUNIT  = 'HPa'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FPC'
      CTITLE = 'CONVECTIVE PRECIPITATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FPL'
      CTITLE = 'LARGE SCALE PRECIPITATION (ATMOSPHERIC FORCING)'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!!      CMARK  = 'FCLD'
!!      CTITLE = 'CLOUD AMOUNT (ATMOSPHERIC FORCING)'
!!      CUNIT  = ''
!!      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'FU'
      CTITLE = 'WIND VELOCITY (ATMOSPHERIC FORCING)'
      CUNIT  = 'M/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
#endif
!
      end  subroutine gswp2_monit_regist_forcings 
!
end module gswp2