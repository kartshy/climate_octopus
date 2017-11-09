Octopus use case based on toy climate model

There are two directories 
1. greb-ucm-master - S 
2. greb-ucm-reader - A

"S" is a toy model that creates output data per timestep of the model run.
It takes as input the output directory location.

Example : ./greb.x ./output/test1

Model run two different runs, control and scenario and creates a file for each run.

"A" creates a monthly mean of the data from the timestep data. It takes as input 
1. the output directory of the model
2. the runs to process control or scenario

Example : ./greb.analyser.x ./output/test1 control

Refer to the README files in each folder for building a running the applications.
The namelist file acts as a metadata for the data. 

A sample workflow is provided in greb_wf.sh.

Manager Requirement

1. The Manager should be able to schedule analyses of control and scenario when they data/file becomes available.
2. The Workflow is of type SAA but there is no dependencies between the the two analysis jobs.
3. The "A" jobs does monthly mean of data and ideally they dont have to wait for the full file to be written, 
instead they can receive data as they are produced.

CDO Requirement

1. The data is represented by 5 fortran arrays of type real(xdim,ydim,time). They are produced every timestep by "S".
2. The "A" has the same data type but they represent monthly mean. The timestep data is read and aggregated as monthly mean
3. The namelist file provides the metadata for the data and the CDO should also include this which can be read at the "A" side.
4. This is a serial application.

Transport requirement

1. able to transport between "S" and "A"s periodically with additional timestep information to create monthly means.
2. "S" and "A" are separate processes and two "A" start after a delay based on the dependency. 


