
## Climate Octopus use case based on the  Monash Climate Model.
This is the Model - S

For more information about the model, please visit:   
http://users.monash.edu.au/~dietmard/content/GREB/GREB_model.html   
http://maths-simpleclimatemodel-dev.maths.monash.edu/   
https://blogs.monash.edu/climate/2012/12/13/the-monash-simple-climate-model/

## Prerequisites

To compile this model, a fortran compiler such as gfortran must be installed already.

## How to install, compile and run

1. Download the repository to your computer (either using git or the .zip file).
From the command line, go to the main model directory.

2. To compile greb-ucm with gfortran into the executable file `greb.x`, 
    ```
    make greb 
    ```

3. To run greb-ucm with the model output and parameters stored in the directory `output/test`,
    ```
    ./greb.x output/test 
    ```

4. Go to the main output directory, check for files control and scenario
    ```
    cd output/test
    ```

The model does two runs 
1. control run
2. scenario run

## Output : control and scenario files contain the following data for control and scenarion runs.

The following variables are output from the model with dimensions [nlon,nlat,ntime]
- Tmm  : near surface temperature, timestep
- Tamm : atmospheric temperature, timestep
- Tomm : deep ocean temperature, timestep
- qmm  : atmospheric moisture, timestep 
- apmm : planetary albedo, timestep 
