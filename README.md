# fine-grained-geo-obfuscation

**Installation**: MATLAB (MATLAB 2022a or later vision): https://www.mathworks.com/products/matlab.html

**Usage**: Run the "main.m" file. After installing MATLAB, open "main.m" and use the "Run" button in the "Live Editor" tab. 

**Variables**: The definition of the variables in the code: <br />
*EPSILON*: Privacy budget <br />
*ETA*: Quality loss constraint constant <br />
*overallcost*: the expected quality loss <br />
*running_time*: the total running time <br />
*peerMatrix_mean*: the averagge number of constraints in the constraint matrix <br />
*peerNeighbor_mean*: the average number of peering neighbors <br />
*cost_distribution*: the distribution of quality loss of different tasks <br />
*running_time_init*: the running time to initiate the column generation (CG) algorithm <br />
*running_time_master*: the running time of the master program of the CG algorithm <br />
*running_time_dual*: the running time of the dual problem of the CG algorithm <br />
*running_time_subproblem*: the running time of the subproblems of the CG algorithm <br />
*eie_distribution*: the distribution of the expected inference error <br />
*iter_stop* the number of itrations to terminate the CG algorithm <br />


**Additional Notes**: Note that the vehicle trajectory dataset from the Shenzhen Institute of Advanced Technology has not been publicly released. Therefore, we are unable to provide vehicle GPS density in this code. Instead, we assume that vehicles are uniformly distributed throughout the target region.
