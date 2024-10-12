[toc]

# Set up HOOMD-blue benchmark

## Clone HOOMD-blue codes

The following commands

1. Created a workspace directory for HOOMD-blue under `scratch` directory
2. Clone latest `HOOMD-blue` and `hoomd-benchmarks` code to the work directory
4. Create the `initial_configuration_cache` directory to hold the initial condition files
4. Copy the initial configuration file prepared at `/scratch/users/industry/ai-hpc/apacsc22/public` to the `initial_configuration_cache` directory

```bash
mkdir ${HOME}/scratch/workdir/hoomd -p
time git -C ${HOME}/scratch/workdir/hoomd clone https://github.com/glotzerlab/hoomd-blue  --recursive
# real	0m39.619s
time git -C ${HOME}/scratch/workdir/hoomd clone https://github.com/glotzerlab/hoomd-benchmarks
# real	0m9.741s
mkdir -p ${HOME}/scratch/workdir/hoomd/initial_configuration_cache
cp /scratch/users/industry/ai-hpc/apacsc22/public/2024-apac-hpc-ai/hoomd/initial_configuration_cache/hard_sphere_200000_1.0_3.gsd \
${HOME}/scratch/workdir/hoomd/initial_configuration_cache
```

## Create Python 3 environment

The following commands

1. Set up a Python 3 Conda environment
2. Install latest `pybind11(2.13.5)` with PIP, to fix `pybind11 version(v2.10.1)` issue caused by wrong HOOMD-blue prerequisite list in the HOOMD-blue git code
3. Run`install-prereq-headers.py` scripts that provided by HOOMD-blue developers
4. Install `GSD` and `numpy`

```bash
time ${HOME}/miniconda/bin/conda create -p ${HOME}/scratch/workdir/hoomd/hoomd.py312 python=3.12 -y
# real	1m12.480s
time ${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/pip install pybind11
# real	0m2.986s
time ${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/python3 ${HOME}/scratch/workdir/hoomd/hoomd-blue/install-prereq-headers.py -y
# real	0m25.010s
time ${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/pip install numpy gsd
# real	0m10.627s

# An alternative approch to fix the pybind11 issue is to correct the wrong version number in prereq script
# sed -i 's|pybind11/archive/v2.10.1.tar.gz|pybind11/archive/v2.13.5.tar.gz|g' hoomd-blue/install-prereq-headers.py
```

## Build HOOMD-blue with ASPIRE-2A OpenMPI

The following commands

1. Check available MPI libraries that pre-built by the Supercomputer administrator
2. Load OpenMPI environment variables
3. Configure the scripts for building HOOMD-blue with OpenMPI and pip-installed `pybind11`
4. Build the Python package
5. Validate the built Python package

```bash
module list | grep -i mpi
module purge
module avail 2>&1 | grep mpi
module load openmpi/4.1.2-hpe
module load libfabric/1.11.0.4.125

rm -fr ${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi-4.1.2-hpe

time PATH=${HOME}/scratch/workdir/hoomd/hoomd.py312/bin:$PATH \
cmake \
-B ${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi-4.1.2-hpe \
-S ${HOME}/scratch/workdir/hoomd/hoomd-blue \
-D ENABLE_MPI=on \
-D MPI_HOME=$OPENMPI_DIR \
-D cereal_DIR=${HOME}/scratch/workdir/hoomd/hoomd.py312/lib64/cmake/cereal \
-D Eigen3_DIR=${HOME}/scratch/workdir/hoomd/hoomd.py312/share/eigen3/cmake \
-D pybind11_DIR=${HOME}/scratch/workdir/hoomd/hoomd.py312/lib/python3.12/site-packages/pybind11/share/cmake/pybind11
# real 0m19.902s
```

Option 1: Allocate a compute node to build the application

```bash
echo "hostname && lscpu && free -g" | qsub -l select=1 -l walltime=00:00:01 -P 50000022

echo "module purge && module load openmpi/4.1.2-hpe && \
time cmake --build ${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi-4.1.2-hpe \
-j $((128*1)) 2>&1 | tee ${HOME}/buildhoomd-openmpi-4.1.2-hpe.log " | qsub \
-l select=1:ncpus=$((128*1)):mem=$((128*2))G \
-l walltime=00:10:01 -P 50000022 -N buildhoomd-openmpi-4.1.2-hpe
# 3m22.801s

qstat
qstat -f
tail -f ${HOME}/buildhoomd-openmpi-4.1.2-hpe.log
```

Option 2: Build the application from login node, while the CPU allocation has been limited to 4 by Control Group policy

```bash
time cmake --build ${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi-4.1.2-hpe -j 4
# real 14m19.211s
```

Validate the built package

```bash
# Validate the built package by loading it with Python
PYTHONPATH=${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi-4.1.2-hpe \
${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/python \
-m hoomd
# python: No module named hoomd.__main__; 'hoomd' is a package and cannot be directly executed
```

## Get Familiar with ASPIRE-2A PBS allocation

Run the following 1-second request with different qsub resource definition parameters, and check the output files. 

```bash
#!/bin/bash
#PBS -P 50000022
#PBS -l walltime=1
#PBS -j oe
#PBS -M 393958790@qq.com
#PBS -m abe
##PBS -l other=hyperthread

module purge
module load openmpi/4.1.2-hpe
module load libfabric/1.11.0.4.125

env
lscpu

mpirun --report-bindings \
-oversubscribe -use-hwthread-cpus \
hostname
```

Submit it

```bash
qsub -l select=2:ncpus=127 hostname.sh
```



# Run the Task 

## Create PBS bash script

Create a shell script file, `${HOME}/run/hoomd.sh`, with following contents

```bash
#!/bin/bash
#PBS -P 50000022
#PBS -l walltime=00:00:60
#PBS -j oe
#PBS -M 393958790@qq.com
#PBS -m abe
##-map-by ppr:$((2*${NCPUS})):node \
##-bind-to hwthread -use-hwthread-cpus \
##-report-bindings \

date
module purge
module load openmpi/4.1.2-hpe
module load libfabric/1.11.0.4.125

cmd="time mpirun \
-mca opal_common_ucx_opal_mem_hooks 1 \
-wdir ${HOME}/scratch/workdir/hoomd \
-output-filename ${HOME}/run/output/${PBS_JOBNAME}.${PBS_JOBID} \
-oversubscribe \
-map-by ppr:$((1*${NCPUS})):node \
-bind-to core \
-x PYTHONPATH=${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi-4.1.2-hpe:${HOME}/scratch/workdir/hoomd/hoomd-benchmarks \
${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/python \
-m hoomd_benchmarks.md_pair_wca \
--device CPU -v \
-N ${N} --repeat ${repeat} \
--warmup_steps ${warmup_steps} --benchmark_steps ${benchmark_steps}"

echo ${cmd}

exec ${cmd}
date
```

## Submit the job script to PBS

The following command

1. Define the number of nodes as an environment variable to set the job scale.
2. Submit the PBS job script to normal queue(CPU queue)

```bash
# submit.hoomd.sh in reference directroy
cd ${HOME}/run

nodes=8 walltime=00:00:200 \
warmup_steps=40000 benchmark_steps=80000 repeat=1 N=200000 \
bash -c \
'qsub -V \
-l walltime=${walltime},select=${nodes}:ncpus=$((128*1)):mem=$((128*2))gb \
-N hoomd.nodes${nodes}.WS${warmup_steps}.BS${benchmark_steps}.N${N} \
hoomd.sh'

```



# Read the results

The performance results of HOOMD-blue are measured in “time steps per second”. The higher the value, the better.

```bash
$ grep "time steps per second" ${HOME}/run/hoomd*.N200000.* |sort  --version-sort
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes1.WS40000.BS80000.N200000.o8345790:.. 1096.3271246089932 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes2.WS40000.BS80000.N200000.o8345789:.. 1813.647534468598 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes4.WS40000.BS80000.N200000.o8345788:.. 2741.2158594414154 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes8.WS40000.BS80000.N200000.o8345799:.. 3105.8205873044612 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes16.WS40000.BS80000.N200000.o8345796:.. 3173.907433941861 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes16.WS100000.BS160000.N200000.o8345825:.. 3394.945583796434 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes32.WS40000.BS80000.N200000.o8345804:.. 3877.4799695443335 time steps per second
/home/users/industry/ai-hpc/apacsc22/run/hoomd.nodes32.WS100000.BS160000.N200000.o8345824:.. 3897.469465640859 time steps per second
```
