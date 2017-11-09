## Climate Octopus use case based on the  Monash Climate Model.
## This is the Model - A
## GREB-Analyser

## Prerequisites

To compile this model, a fortran compiler such as gfortran must be installed already.

## How to install, compile and run

1. Download the repository to your computer (either using git or the .zip file).
From the command line, go to the main model directory.

2. To compile greb-analyser with gfortran into the executable file `greb.analyser.x`, 
    ```
    make greb 
    ```

3. To run greb-analyser with the model output and parameters stored in the directory `output/test`,
    ```
    ./greb.analyser.x output/test control
    ./greb.analyser.x output/test scenario
    ```

4. Go to the main output directory, look for files control.mean and scenario.mean
    ```
    cd output/test
    ```

## Output diagnostics 

The following variables are output from the model with dimensions [nlon,nlat,ntime]
- Tmm  : near surface temperature, monthly mean
- Tamm : atmospheric temperature,  monthly mean
- Tomm : deep ocean temperature, monthly mean 
- qmm  : atmospheric moisture, monthly mean 
- apmm : planetary albedo, monthly mean 
