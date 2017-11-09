!
!----------------------------------------------------------
!   The Globally Resolved Energy Balance (GREB) Model 
!----------------------------------------------------------
!
!   Authors; Dietmar Dommenget and Janine Flöter 
!            with numerical opitmizations by Micheal Rezny
!
!   Reference: Conceptual Understanding of Climate Change with a Globally Resolved Energy Balance Model
!            by Dietmar Dommenget and Janine Flöter, submitted to Climate Dynamics 2010.
!
! 
!  input fields: The GREB model needs the following fields to be specified before 
!                the main subroutine greb_model is called:
!
!   z_topo(xdim,ydim):            topography (<0 are ocean points) [m]
!  glacier(xdim,ydim):            glacier mask ( >0.5 are glacier points )
!    Tclim(xdim,ydim,nstep_yr):   mean Tsurf                       [K]
!    uclim(xdim,ydim,nstep_yr):   mean zonal wind speed            [m/s]
!    vclim(xdim,ydim,nstep_yr):   mean meridional wind speed       [m/s]
!    qclim(xdim,ydim,nstep_yr):   mean atmospheric humidity        [kg/kg]
!  mldclim(xdim,ydim,nstep_yr):   mean ocean mixed layer depth     [m]
!   Toclim(xdim,ydim,nstep_yr):   mean deep ocean temperature      [K]
! swetclim(xdim,ydim,nstep_yr):   soil wetnees, fraction of total  [0-1]
! sw_solar(ydim,nstep_yr):        24hrs mean solar radiation       [W/m^2]
!
!
!+++++++++++++++++++++++++++++++++++++++
module mo_numerics
!+++++++++++++++++++++++++++++++++++++++

! declare output folder name (ajr, 2014-03-11)
  character(len=256) :: outfldr 
  character(len=256) :: cs
! numerical parameter
  integer, parameter :: xdim = 96, ydim = 48          ! field dimensions
  integer, parameter :: ndays_yr  = 365               ! number of days per year
  integer, parameter :: dt        = 12*3600           ! time step [s]
  integer, parameter :: dt_crcl   = 0.5*3600          ! time step circulation [s]  
  integer, parameter :: ndt_days  = 24*3600/dt        ! number of timesteps per day
  integer, parameter :: nstep_yr  = ndays_yr*ndt_days ! number of timesteps per year
  integer            :: time_flux = 0                 ! length of integration for flux correction [yrs]
  integer            :: time_ctrl = 0                 ! length of integration for control run  [yrs]
  integer            :: time_scnr = 0                 ! length of integration for scenario run [yrs]
  integer            :: ipx       = 1                 ! points for diagonstic print outs
  integer            :: ipy       = 1                 ! points for diagonstic print outs
  integer, parameter, dimension(12) :: jday_mon = (/31,28,31,30,31,30,31,31,30,31,30,31/) ! days per 
  real, parameter    :: dlon      = 360./xdim         ! linear increment in lon
  real, parameter    :: dlat      = 180./ydim         ! linear increment in lat

  integer            :: ireal     = 4         ! record length for IO (machine dependent)
! 												ireal = 4 for Mac Book Pro 

  namelist / numerics / time_flux, time_ctrl, time_scnr

end module mo_numerics

!+++++++++++++++++++++++++++++++++++++++
module mo_physics
!+++++++++++++++++++++++++++++++++++++++

  use mo_numerics
  integer  :: log_exp = 0                ! process control logics for sens. exp.

! physical parameter (natural constants)
  parameter( pi        = 3.1416 )  
  parameter( sig       = 5.6704e-8 )     ! stefan-boltzmann constant [W/m^2/K^4]
  parameter( rho_ocean = 999.1 )         ! density of water at T=15C [kg/m^2]
  parameter( rho_land  = 2600. )         ! density of solid rock [kg/m^2]
  parameter( rho_air   = 1.2 )           ! density of air at 20C at NN 
  parameter( cp_ocean  = 4186. )         ! specific heat capacity of water at T=15C [J/kg/K]
  parameter( cp_land   = cp_ocean/4.5 )  ! specific heat capacity of dry land [J/kg/K]
  parameter( cp_air    = 1005. )         ! specific heat capacity of air      [J/kg/K]
  parameter( eps       = 1. )            ! emissivity for IR

! physical parameter (model values)
  parameter( d_ocean   = 50. )                     ! depth of ocean column [m]  
  parameter( d_land    = 2. )                      ! depth of land column  [m]
  parameter( d_air     = 5000. )                   ! depth of air column   [m]
  parameter( cap_ocean = cp_ocean*rho_ocean )      ! heat capacity 1m ocean  [J/K/m^2] 
  parameter( cap_land  = cp_land*rho_land*d_land ) ! heat capacity land   [J/K/m^2]
  parameter( cap_air   = cp_air*rho_air*d_air )    ! heat capacity air    [J/K/m^2]
  parameter( ct_sens   = 22.5 )                    ! coupling for sensible heat
  parameter( da_ice    = 0.25 )                    ! albedo diff for ice covered points
  parameter( a_no_ice  = 0.1 )                     ! albedo for non-ice covered points
  parameter( a_cloud   = 0.35 )                     ! albedo for clouds
  parameter( Tl_ice1   = 273.15-10. )              ! temperature range of land snow-albedo feedback
  parameter( Tl_ice2   = 273.15  )                 ! temperature range of land snow-albedo feedback
  parameter( To_ice1   = 273.15-7. )               ! temperature range of ocean ice-albedo feedback
  parameter( To_ice2   = 273.15-1.7 )              ! temperature range of ocean ice-albedo feedback 
  parameter( co_turb   = 5.0 )                     ! turbolent mixing to deep ocean [W/K/m^2]
  parameter( kappa     = 8e5 )                     ! atmos. diffusion coefficient [m^2/s]
  parameter( ce        = 2e-3  )                   ! laten heat transfer coefficient for ocean
  parameter( cq_latent = 2.257e6 )                 ! latent heat of condensation/evapoartion f water [J/kg]
  parameter( cq_rain   = -0.1/24./3600. )          ! decrease in air water vapor due to rain [1/s]
  parameter( z_air     = 8400. )                   ! scaling height atmos. heat, CO2
  parameter( z_vapor   = 5000. )                   ! scaling height atmos. water vapor diffusion
  parameter( r_qviwv   = 2.6736e3)                 ! regres. factor between viwv and q_air  [kg/m^3]

! parameter emissivity
  real, parameter, dimension(10) :: p_emi = (/9.0721, 106.7252, 61.5562, 0.0179, 0.0028,     &
&                                             0.0570, 0.3462, 2.3406, 0.7032, 1.0662/)

! declare climate fields
  real, dimension(xdim,ydim)          ::  z_topo, glacier,z_ocean
  real, dimension(xdim,ydim,nstep_yr) ::  Tclim, uclim, vclim, qclim, mldclim, Toclim, cldclim
  real, dimension(xdim,ydim,nstep_yr) ::  TF_correct, qF_correct, ToF_correct, swetclim, dTrad
  real, dimension(ydim,nstep_yr)      ::  sw_solar

! declare constant fields
  real, dimension(xdim,ydim)          ::  cap_surf
  integer jday, ityr

! declare some program constants
  real, dimension(xdim, ydim)         :: wz_air, wz_vapor
  real, dimension(xdim,ydim,nstep_yr) :: uclim_m, uclim_p 
  real, dimension(xdim,ydim,nstep_yr) :: vclim_m, vclim_p 

  real :: t0, t1, t2

  namelist / physics / log_exp
  
end module mo_physics

!+++++++++++++++++++++++++++++++++++++++
module mo_diagnostics
!+++++++++++++++++++++++++++++++++++++++

  USE mo_numerics,    ONLY: xdim, ydim

 ! declare diagnostic fields
  real, dimension(xdim,ydim)          :: Tsmn, Tamn, qmn, swmn, lwmn, qlatmn, qsensmn, &
&                                        ftmn, fqmn, amn, Tomn

! declare output fields
  real, dimension(xdim,ydim)          :: Tmm, Tamm, Tomm, qmm, apmm

end module mo_diagnostics

!+++++++++++++++++++++++++++++++++++++++
subroutine greb_model
!+++++++++++++++++++++++++++++++++++++++

  use mo_numerics
  use mo_physics
  use mo_diagnostics
  
  integer:: it, irec =0
  open(22,file=trim(outfldr)//trim(cs),ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
  open(23,file=trim(outfldr)//trim(cs)//".mean",ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
 
  Tsmn=0.0;
  Tamn=0.0;
  Tomn=0.0;
  qmn=0.0;
  amn=0.0;
  mon=1;

  do it=1, time_ctrl*nstep_yr                                             ! main time loop
    jday = mod((it-1)/ndt_days,ndays_yr)+1  ! current calendar day in year
    read(22,rec=it)   Tmm
    read(22,rec=it+1) Tamm
    read(22,rec=it+2) Tomm
    read(22,rec=it+3) qmm
    read(22,rec=it+4) apmm
    Tsmn = Tsmn + Tmm
    Tamn = Tamn + Tamm
    Tomn = Tomn + Tomm
    qmn = qmn + qmm
    amn = amn + apmm
    if (       jday == sum(jday_mon(1:mon))                   &
       &      .and. it/float(ndt_days) == nint(it/float(ndt_days)) ) then
       ndm=jday_mon(mon)*ndt_days
      irec=irec+1; write(23,rec=irec)  Tsmn/ndm
      irec=irec+1; write(23,rec=irec)  Tamn/ndm
      irec=irec+1; write(23,rec=irec)  Tomn/ndm
      irec=irec+1; write(23,rec=irec)  qmn/ndm
      irec=irec+1; write(23,rec=irec)  amn/ndm

      print*,"Month :", mon
      print*, Tsmn(48,24)/ndm
      print*, Tamn(48,24)/ndm
      print*, Tomn(48,24)/ndm
      print*, qmn(48,24)/ndm
      print*, amn(48,24)/ndm
 
      Tsmn=0.0;
      Tamn=0.0;
      Tomn=0.0;
      qmn=0.0;
      amn=0.0;
      mon=mon+1; if (mon==13) mon=1
    end if

  end do
end subroutine

