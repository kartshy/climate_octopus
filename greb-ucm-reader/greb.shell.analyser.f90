  program  time_ex

  USE mo_numerics
  USE mo_physics

  integer :: narg 

100 FORMAT('climate: ',F9.2, 5E12.4)

  print*,'% start climate shell'

  ipx=46; ipy=24+8
  print*,'% diagonstic point lat/lon: ',3.75*ipy-90, 3.75*ipx
  
! Define output directory and copy namelist there
! (ajr, 2014-03-11)
! #####
  narg    = command_argument_count()
  outfldr = "output/default/"
  if (narg .gt. 0) call get_command_argument(1,outfldr)
  outfldr = trim(adjustl(outfldr))
  i = len(trim(outfldr))
  
  cs = "scenario"
  if (narg .gt. 1) call get_command_argument(2,cs)
  cs = trim(adjustl(cs))

  print*, "Running ", cs

  if ( scan(trim(outfldr),"/",back=.TRUE.) .ne. i ) outfldr = trim(outfldr)//"/"
  call execute_command_line ('mkdir -p ' // trim(outfldr) )
  call execute_command_line ('cp namelist ' // trim(outfldr)//"/" )
! ####

  open(10,file=trim(outfldr)//'namelist')

! read namelist 
  read(10,numerics)
  read(10,physics) 

  print*,'% time flux/control/scenario: ', time_flux, time_ctrl, time_scnr  
  call greb_model
  
  END
