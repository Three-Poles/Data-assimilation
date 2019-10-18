! forcing_shortwave.F90 - �Z�g���˂̕��
! vi: set sw=2 ts=72:

!=======================================================================
! forcing_read_shortwave - �Z�g���˗p���}�ǂݎ�胋�[�`��
!   forcing_read_id �̒Z�g���˗p�ގ����i�������̂����d�l�������B
!   ���� id �ȑO�ł����Ƃ��x���f�[�^���� id1 �����߁A���̎��̃f�[�^����
!   id2 �Ƃ̊ԂœV���p�]���ŏd�ݕt���ϕ������Ă���ĕ��l��Ԃ��B
!   delt_atm, glon, glat, imask �͓V���p�]���̌v�Z�ɗp����B

subroutine forcing_read_shortwave( &
  cmark_swdn, cmark_cld, id, delt_atm, glon, glat, imask, &! IN
  swdn, rvisb, rvisd, rnirb, rnird, zmean_phy, ztemp_phy, cloudiness &! OUT
)
  use forcing, only: IDIM, JDIM, forcing_read_id2, forcing_read_nearest_id
  use com_step, only: icnsw
  use date
  implicit none
  character(len = 4), intent(in):: cmark_swdn
  character(len = 4), intent(in):: cmark_cld
  integer, intent(in):: id(5)
  real(8), intent(in):: delt_atm
  real(8), intent(in):: glon(IDIM, JDIM)
  real(8), intent(in):: glat(IDIM, JDIM)
  integer, intent(in):: imask(IDIM, JDIM)
  real(8), intent(out):: swdn(IDIM, JDIM)
  real(8), intent(out):: rvisb(IDIM, JDIM)
  real(8), intent(out):: rvisd(IDIM, JDIM)
  real(8), intent(out):: rnirb(IDIM, JDIM)
  real(8), intent(out):: rnird(IDIM, JDIM)
  real(8), intent(out):: zmean_phy(IDIM, JDIM)
  real(8), intent(out):: ztemp_phy(IDIM, JDIM)
  real(8), intent(out):: cloudiness(IDIM, JDIM)  ! �_��
  real:: buf1(IDIM, JDIM)  ! �����̑����ق��̃f�[�^
  real:: buf2(IDIM, JDIM)  ! �����̒x���ق��̃f�[�^
  real(8):: weight  ! �����ł͎g��Ȃ�
  integer:: id1(5)  ! �f�[�^�̑����ق��̎���
  integer:: id2(5)  ! �f�[�^�̒x���ق��̎���
  real(8), save:: delt_data  ! ��Ԃ��ׂ�2�̃f�[�^�̎����̊Ԋu [�b]
  integer:: idiff(5)  ! �����̊Ԋu
  integer:: id_base(5)  ! �����̋N�_
  integer:: idiff_span(5)  ! �����̊Ԋu
  integer:: id_afterspan(5)  ! �����̏I�_
  real(8):: rday  ! �N������̎��� [�N]
  real(8):: rsec  ! ���q����̎��� [��]
  logical:: update  ! �ǂݎ��ɂ���� buf1, buf2 ���X�V���ꂽ�ꍇ�^
  ! �V���p�]���ŏd�݂������X�e�b�v���ƒZ�g���˗�
  real(8), save:: sr_flux_work(IDIM, JDIM)
  ! sr_flux_work ���v�Z���������B�����l�͂��肦�Ȃ����t
  integer, save:: id_sr(5) = (/0, 0, 0, 0, 0/)
  logical, save:: lfirst = .TRUE.
  integer:: nsteps_rad
! ---
  !
  ! ���� id �ȑO�ł����Ƃ��x���f�[�^���� id1 �Ƃ��̎��̃f�[�^���� id2 ��
  ! ���߂�Bid1 ���V�����Ȃ����Ƃ��� update ���^�ɂȂ�Asr_flux_work ��
  ! �X�V�����B�v�Z�����ƃf�[�^�������d�Ȃ����Ƃ��ɂ͍X�V���ׂ��Ȃ̂ŁA
  ! id + 1[sec] �̑O��Ō�������B�f�[�^�Ԋu��2�b�ȏ�ł��邱�Ƃ�����B
  !
  id_afterspan(:) = id(:)
  id_afterspan(5) = id_afterspan(5) + 1
  call forcing_read_id2(cmark_swdn, id_afterspan, &! IN
    id1, buf1, id2, buf2, weight, update) ! OUT
  if (all(id1 == id2)) update = .FALSE.
  !
  ! �v���O�����N�����Ƀr���S���Ă��܂�����~�ϑ[�u
  ! (���� - 1sec �ŋN�����Ȃ�������s�v)
  !
  if (lfirst .and. .not. update) then
    call forcing_read_id2(cmark_swdn, id, &! IN
      id1, buf1, id2, buf2, weight, update) ! OUT
  endif
  if (lfirst) lfirst = .FALSE.
  if (update) then
    ! �܂� idiff = id2 - id1
    call date_diff(id2, id1, idiff)
    ! �܂� delt_data = idiff / 1[sec]
    call date_diff_div(idiff, (/0, 0, 0, 0, 1/), delt_data)
  endif
  if (delt_data == 0.0_8) delt_data = 3600.0_8 * 6.0_8  ! ���S��

  ! id1 ���� rday �����߂�
  ! �܂� rday = (id1 - id1#yr#Jan1) / ((id1#yr + 1)#Jan1 - id1#yr#Jan1)
  id_base(:) = id1(:)
  id_base(2:5) = (/1, 1, 0, 0/)
  call date_diff(id1, id_base, idiff)
  id_afterspan(:) = id_base(:)
  id_afterspan(1) = id_afterspan(1) + 1
  call date_diff(id_afterspan, id_base, idiff_span)
  call date_diff_div(idiff, idiff_span, rday)

  ! id ���� rsec �����߂�
  ! �܂� rsec = (id1 - id1#day#0am) / ((id1#day + 1)#0am - id1#day#0am)
  id_base(:) = id(:)
  call date_normalize(id_base)
  rsec = (id_base(4) * 3600.0_8 + real(id_base(5), kind=8)) / 86400.0_8
#ifdef DEBUG
  print *, 'forcing_shortwave_step', id_base, rsec
#endif

  ! �V�����f�[�^�����ɒB�����Ȃ�΃X�e�b�v�����ϕ��˂����߂�
  if (update) then
    call forcing_shortwave_average( &
      rday, rsec, delt_atm, delt_data, glon, glat, imask, &! IN
      buf1, &! INOUT
      sr_flux_work) ! OUT
  endif

  ! icnsw ���^�ɂȂ����X�e�b�v���ɕ��˂��v�Z����
  if (icnsw == 1) then
    call forcing_shortwave_step( &
      rday, rsec, delt_atm, sr_flux_work, glon, glat, &! IN
      nsteps_rad, swdn, zmean_phy) ! OUT
    call forcing_read_nearest_id(cmark_cld, cloudiness, id, 0.5_8)
    cloudiness(:, :) = cloudiness(:, :) / 100.0_8
    call forcing_shortwave_divide( &
      rvisb, rvisd, rnirb, rnird, &! OUT
      swdn, cloudiness, zmean_phy) ! IN
  endif
  call islscp_sunang(rday,  rsec,  glon,  glat, &! IN
    ztemp_phy) ! OUT
  ztemp_phy(:, :) = max(ztemp_phy(:, :), 0.0_8)

end subroutine

!=======================================================================
! forcing_shortwave_average - �Z�g���˗ʂ�V���p�ňĕ����邽�߂̏���
!   �Z�g���˗� rswd �����ԕ��ϗ]���V���p�Ŋ���Asr_flux_work ��
!   �쐬����B���̒l�ɂ�肠�Ƃŗ]���V���p cosz �������ăt���b�N�X���v�Z����B
!   �ϕ����Ԃ͋G�� rday �̎��� rsec ���� delt_data �b�ł���B

subroutine forcing_shortwave_average( &
  rday, rsec, delt_atm, delt_data, &! IN
  glon, glat, imask, &! IN
  rswd, &! INOUT
  sr_flux_work &! OUT
)
  ! cosz_min �͐��̒l�������Ƃ����肵�Ă���
  use sibcon, only: cosz_min_c
  use prm, only: idim, jdim 
  use message, only: message_put
  !
  implicit none
  !
  real, intent(inout):: rswd(idim, jdim)
  real(8), intent(in):: rday 
  real(8), intent(in):: rsec
  real(8), intent(in):: delt_atm
  real(8), intent(in):: delt_data
  integer, intent(in):: imask(idim, jdim)
  real(8), intent(in):: glon(idim, jdim)
  real(8), intent(in):: glat(idim, jdim)
  !
  real(8), intent(out):: sr_flux_work(idim, jdim) 
  !
  integer:: i
  integer:: j
  integer:: ist
  integer:: nsteps_6hr 
  real(8):: dsec 
  !
  real(8):: cosz        (idim, jdim) 
  real(8):: cosz_sum    (idim, jdim) 
  !
  ! ----------------------
  ! > delt_data �b�Ԃ̃X�e�b�v�� < 
  ! ----------------------
  !
  nsteps_6hr = (delt_data + 1.0) / delt_atm 
  !
  ! ------------------
  ! > �f�[�^�`�F�b�N <
  ! ------------------
  !   -10 �ȉ�����������͂˂�B-10<rswd<0 �Ȃ�΃��b�Z�[�W��f���� 0 �ɂ���B
  !
  do j=1, jdim
    do i=1, idim
!     if (rswd(i, j) < -1.0) then 
      if (rswd(i, j) < -10.0) then 
        write(6, *) 'rswd forcing_shortwave_average severe warning',  &
          i,  j,  rswd(i, j), 'is modified to 0'
        rswd(i, j) = 0.0
        stop 999
      elseif (rswd(i, j) < 0.0) then 
        write(6, *) 'rswd forcing_shortwave_average warning', &
          i,  j,  rswd(i, j), 'is modified to 0'
        rswd(i, j) = 0.0
      endif
    enddo 
  enddo 
  !
  ! --------------------------------------------------
  ! > delt_data �b�Ԃ̊Ԃ̊e�X�e�b�v�ł̓V���p�̌v�Z�A���ώZ <
  ! --------------------------------------------------
  !
  cosz_sum (:,:) = 0.d0
  !
  do ist = 1, nsteps_6hr
    dsec = rsec + delt_atm / 86400.d0 * ( ist - 0.5d0 ) 
    call islscp_sunang(rday,  dsec,  glon,  glat, &! IN
      cosz) ! OUT
    where (cosz >= cosz_min_c)
      cosz_sum = cosz_sum + cosz
    end where
  enddo
  !
  !   (3) �f�[�^�`�F�b�N
  !
  do j=1, jdim
    do i=1, idim
  !
  !         �Z�g������̂ɓV���p�̘a�����Ȃ�΁A�x���A�Z�g�̓[����
      if (rswd(i, j) > 0.0 .and. cosz_sum(i, j) < cosz_min_c &
        .and. imask(i, j) /= 0) then
        call message_put("forcing_shortwave: rswd>0 cosz=0")
#       if defined(DEBUG) || defined(CHECK)
          write(6, *) i,  j,  rswd(i, j),  cosz_sum(i, j) 
#       endif
        rswd(i, j) = 0.
  !
  !         �Z�g���Ȃ��̂ɓV���p�̘a�����Ȃ�΁A�x���B
      elseif (rswd (i, j) <= 0.0 .and. cosz_sum(i, j) >= cosz_min_c &
        .and. imask(i, j) /= 0) then
        call message_put("forcing_shortwave: rswd=0 cosz>0")
#       if defined(DEBUG) || defined(CHECK)
          write(6, *) i,  j,  rswd(i, j),  cosz_sum(i, j) 
#       endif
      endif
    enddo
  enddo
  !
  !   (4) s/cos�� �̌v�Z
  !       sr_flux_work * cosz ���t���b�N�X�ɂȂ�悤�ɂ���B
  !
  !       cosz_sum �����܂�ɏ������Ƃ��́A�Z�g���ɂ��Ă��܂��B
  !       �Q�͖����낤�B�����B
  !
  !       rswd �͓�������ł���Ԃ��܂߂� delt_data �b�Ԃ̕��ρB
  !       ����āA�Z�g���v�� rswd*nsteps_6hr �ŋ��߂Ă����B
  !       cosz/cosz_sum �́A���̂����̔z�����\���B
  !
  sr_flux_work(:,:) = 0.0d0 
  where (cosz_sum >= cosz_min_c)
    sr_flux_work = rswd * nsteps_6hr / cosz_sum
  end where
  !
  return
end subroutine

!================================================================
subroutine forcing_shortwave_step( &
  rday, rsec, delt_atm, sr_flux_work, glon, glat, &! IN
  nsteps_rad, rshrt, zmean_phy) ! OUT
!
!  �Z�g���ˌv�Z�X�e�b�v�̏��� 
!     ���̒Z�g���ˌv�Z�܂ł̕��ς̓V���p�E�Z�g���˂��v�Z����B
!     �ϕ����Ԃ͋G�� rday �̎��� rsec ���� 1 ���Ԃł���B
!
  use prm, only: idim, jdim
    ! jcn_iwl_skip �� �}1 �Ȃ�� ���X�e�b�v���ˌv�Z
  use com_runconf_sib0109, only: jcn_iwl_skip
    ! cosz_min �����ł��邱�Ƃ�����
  use sibcon, only: cosz_min_c
  !
  implicit none
  !
  real(8), intent(in):: rday 
  real(8), intent(in):: rsec
  real(8), intent(in):: delt_atm
  real(8), intent(in):: sr_flux_work(idim, jdim)
  real(8), intent(in):: glon(idim, jdim)
  real(8), intent(in):: glat(idim, jdim)
  real(8), intent(out):: zmean_phy(idim, jdim)
  real(8), intent(out):: rshrt(idim, jdim)
  !
  integer, intent(out):: nsteps_rad
  !
  real(8):: cosz(idim, jdim) 
  real(8):: cosz_sum(idim, jdim) 
  integer:: icosz_sum(idim, jdim) 
  integer:: ist
  real(8):: dsec
  !
  !  �X�e�b�v��
  !
  if (abs(jcn_iwl_skip) == 1) then   
    ! ���X�e�b�v���ˌv�Z
    nsteps_rad = 1 
  else
    ! �ꎞ�ԂɈ�x
    nsteps_rad = 3601 / delt_atm 
  endif  
  !
  cosz_sum(:, :) = 0.d0
  icosz_sum(:, :) = 0
  !
  do ist = 1, nsteps_rad
    dsec = rsec + delt_atm / 86400.d0 *( ist - 0.5d0 ) 
    !
    call islscp_sunang(rday, dsec, glon, glat, &! IN
      cosz) ! OUT
    !
    where (cosz >= cosz_min_c)
      cosz_sum = cosz_sum + cosz
      icosz_sum = icosz_sum + 1
    end where
  enddo
  !
  zmean_phy(:, :) = 0.0
  rshrt(:, :) = 0.0
  where (cosz_sum >= cosz_min_c)
    zmean_phy = cosz_sum / icosz_sum
    rshrt = sr_flux_work * cosz_sum / nsteps_rad
  end where
  !
  return
end subroutine

!=======================================================================
! forcing_shortwave_divide - �Z�g���˂�4�핪��
!   �Z�g���˗� rshort, �_�� cloudiness, �V���p zmean_phy ����
!   ����4���� rvisb, rvisd, rnirb, rnird ���Z�o����

subroutine forcing_shortwave_divide( &
  rvisb, rvisd, rnirb, rnird, &! OUT
  rshort, cloudiness, zmean_phy &! IN
)
  use forcing, only: IDIM, JDIM
  implicit none
  !
  integer, parameter:: double = kind(0.0d0)
  !
  real(double), intent(out):: rvisb(IDIM * JDIM)
  real(double), intent(out):: rvisd(IDIM * JDIM)
  real(double), intent(out):: rnirb(IDIM * JDIM)
  real(double), intent(out):: rnird(IDIM * JDIM)
  real(double), intent(in):: rshort(IDIM * JDIM)
  real(double), intent(in):: cloudiness(IDIM * JDIM)
  real(double), intent(in):: zmean_phy(IDIM * JDIM)
  !
  real(double), parameter:: ZERO = 0.0_double
  real(double), parameter:: UNITY = 1.0_double
  real(double), parameter:: PERCENT = 0.01_double
  real(double):: dif_ratio(IDIM * JDIM)
  real(double):: vn_ratio(IDIM * JDIM)
  !
  ! Goudriaan(1977) �ɂ�鉺�����Z�g���˂̕���
  !
  dif_ratio(:) = 0.0683_double &
    + 0.0604_double / max(PERCENT, ZMEAN_PHY(:) - 0.0223_double)
  dif_ratio(:) = min(UNITY, max(ZERO, dif_ratio(:)))
  dif_ratio(:) = dif_ratio(:) + (1.0_double - dif_ratio(:)) * cloudiness(:)
  vn_ratio(:) = (580.0_double - cloudiness(:) * 464.0_double) &
    / ((580.0_double - cloudiness(:) * 499.0_double) &
      + (580.0_double - cloudiness(:) * 464.0_double))
  rvisb(:) = (1.0_double - dif_ratio(:)) * vn_ratio(:) * rshort(:)
  rvisd(:) = dif_ratio(:) * vn_ratio(:) * rshort(:)
  rnirb(:) = (1.0_double - dif_ratio(:)) * (1.0_double - vn_ratio(:)) * rshort(:)
  rnird(:) = dif_ratio(:) * (1.0_double - vn_ratio(:)) * rshort(:)
end subroutine
