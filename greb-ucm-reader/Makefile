.SUFFIXES: .f .F .F90 .f90 .o .mod
.SHELL: /bin/sh

.PHONY : usage
usage:
	@echo ""
	@echo "    * USAGE * "
	@echo ""
	@echo " make greb      : compiles the main program greb.x"
	@echo " make clean     : cleans object files"
	@echo ""

objdir = .obj

ifort ?= 0
debug ?= 0 

ifeq ($(ifort),1)
    FC = ifort 
else
    FC = gfortran
endif 

ifeq ($(ifort),1)
	## IFORT OPTIONS ##
	FLAGS        = -module $(objdir) -L$(objdir)
	LFLAGS		 = 

	ifeq ($(debug), 1)
	    DFLAGS   = -w -C -traceback -ftrapuv -fpe0 -check all -vec-report0
	else
	    DFLAGS   = -vec-report0 -O -assume byterecl -xhost -align all -fno-alias
	endif
else
	## GFORTRAN OPTIONS ##
	FLAGS        = -I$(objdir) -J$(objdir)
	LFLAGS		 = 

	ifeq ($(debug), 1)
	    DFLAGS   = -w -p -ggdb -ffpe-trap=invalid,zero,overflow,underflow -fbacktrace -fcheck=all
	else
	    DFLAGS   = -O
	endif
endif

## Individual libraries or modules ##
$(objdir)/greb.analyser.o: greb.analyser.f90
	$(FC) $(DFLAGS) $(FLAGS) -c -o $@ $<

greb: $(objdir)/greb.analyser.o
	$(FC) $(DFLAGS) $(FLAGS) -o greb.analyser.x $^ greb.shell.analyser.f90 $(LFLAGS)
	@echo " "
	@echo "    greb.analyser.x is ready."
	@echo " "

clean:
	rm -f greb.analyser.x $(objdir)/*.o $(objdir)/*.mod

