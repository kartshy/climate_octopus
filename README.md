Octopus use case based on toy climate model

There are two directories 
1. greb-ucm-master - S 
2. greb-ucm-reader - A

S is a toy model that creates output data per timestep of the model run.
It takes as input the output directory location.

Example : ./greb.x ./output/test1

Model run two different runs, control and scenario and creates a file for each run.

A creates a monthly mean of the data from the timestep data. It takes as input 
1. the output directory of the model
2. the runs to process control or scenario

Example : ./greb.analyser.x ./output/test1 control

The namelist file acts as a metadata for the data. 

