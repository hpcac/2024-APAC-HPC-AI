[toc]

# Set up HOOMD-blue benchmark

## Clone HOOMD-blue codes

The following commands

1. Created a workspace directory for HOOMD-blue under `scratch` directory
2. Clone latest `HOOMD-blue` and `hoomd-benchmarks` code to the work directory
4. Create the `initial_configuration_cache` directory to hold the initial condition files
4. Copy the initial configuration file prepared at `/scracth/public` to the `initial_configuration_cache` directory

```bash
mkdir ${HOME}/scratch/workdir/hoomd -p
time git -C ${HOME}/scratch/workdir/hoomd clone https://github.com/glotzerlab/hoomd-blue  --recursive
# real	0m39.175s
time git -C ${HOME}/scratch/workdir/hoomd clone https://github.com/glotzerlab/hoomd-benchmarks
# real	0m7.302s
mkdir -p ${HOME}/scratch/workdir/hoomd/initial_configuration_cache
cp /scratch/public/2024-apac-hpc-ai/hoomd/initial_configuration_cache/hard_sphere_200000_1.0_3.gsd \
${HOME}/scratch/workdir/hoomd/initial_configuration_cache
```

## Create Python 3 environment

The following commands

1. Set up a Python 3 Conda environment
2. Install latest `pybind11(2.13.5)` with PIP, to fix `pybind11 version(v2.10.1)` issue caused by wrong HOOMD-blue prerequisite list in the HOOMD-blue git code
3. Run`install-prereq-headers.py` scripts that provided by HOOMD-blue developers
4. Install `GSD` and `numpy`

```bash
time conda create -p ${HOME}/scratch/workdir/hoomd/hoomd.py312 python=3.12 -y
# real	2m1.718s
time ${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/pip install pybind11
# real	0m2.986s
time ${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/python3 ${HOME}/scratch/workdir/hoomd/hoomd-blue/install-prereq-headers.py -y
# real	2m10.649s
time ${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/pip install numpy gsd
# real	0m13.976s

# An alternative approch to fix the pybind11 issue is to correct the wrong version number in prereq script
# sed -i 's|pybind11/archive/v2.10.1.tar.gz|pybind11/archive/v2.13.5.tar.gz|g' hoomd-blue/install-prereq-headers.py
```

## Build HOOMD-blue with OpenMPI

The following commands

1. Check available MPI libraries that pre-built by the Supercomputer administrator
2. Load OpenMPI environment variables
3. Configure the scripts for building HOOMD-blue with OpenMPI and pip-installed `pybind11`
4. Build the Python package
5. Validate the built Python package

```bash
module avail | grep -i mpi
module load openmpi/4.1.5
module load gcc/14.1.0

time PATH=${HOME}/scratch/workdir/hoomd/hoomd.py312/bin:$PATH \
cmake \
-B ${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi4.1.5 \
-S ${HOME}/scratch/workdir/hoomd/hoomd-blue \
-D ENABLE_MPI=on \
-D MPI_HOME=$OPENMPI_ROOT \
-D cereal_DIR=${HOME}/scratch/workdir/hoomd/hoomd.py312/lib64/cmake/cereal \
-D Eigen3_DIR=${HOME}/scratch/workdir/hoomd/hoomd.py312/share/eigen3/cmake \
-D pybind11_DIR=${HOME}/scratch/workdir/hoomd/hoomd.py312/lib/python3.12/site-packages/pybind11/share/cmake/pybind11
# real	0m17.844s

time cmake --build ${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi4.1.5 -j 16
# real	28m38.769s

# Validate the built package by loading it with Python
PYTHONPATH=${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi4.1.5 \
${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/python \
-m hoomd
# python: No module named hoomd.__main__; 'hoomd' is a package and cannot be directly executed
```

## Resolve the LOG_CAT_ML HCOLL issue

To address the HCOLL issue in the pre-built OpenMPI, where you encounter the following error

`[LOG_CAT_ML] component basesmuma is not available but requested in hierarchy: basesmuma,basesmuma,ucx_p2p:basesmsocket,basesmuma,p2p
[LOG_CAT_ML] ml_discover_hierarchy exited with error`

Follow these steps:

1. Download and unpack HPC-X
2. Load HPC-X OpenMPI module file instead of prebuilt openmpi/4.1.5 before launching the MPI task

```bash
time wget -P ${HOME} https://content.mellanox.com/hpc/hpc-x/v2.20/hpcx-v2.20-gcc-mlnx_ofed-redhat8-cuda12-x86_64.tbz
# real	0m34.912s
time tar -C ${HOME} -xf ${HOME}/hpcx-v2.20-gcc-mlnx_ofed-redhat8-cuda12-x86_64.tbz
# real	1m1.152s
```

# Run the Task 

## Create PBS bash script

Create a shell script file, `${HOME}/run/hoomd.sh`, with following contents

```bash
#!/bin/bash
#PBS -j oe
#PBS -M 393958790@qq.com
#PBS -m abe
#PBS -P xs75
#PBS -l ngpus=0
#PBS -l walltime=00:00:60
##PBS -l other=hyperthread
#-report-bindings \

date
module purge
module load ${HOME}/hpcx-v2.20-gcc-mlnx_ofed-redhat8-cuda12-x86_64/modulefiles/hpcx-ompi

hosts=$(sort -u ${PBS_NODEFILE} | paste -sd ',')

cmd="time mpirun \
-host ${hosts} \
-wdir ${HOME}/scratch/workdir/hoomd \
-output-filename ${HOME}/run/output/${PBS_JOBNAME}.${PBS_JOBID} \
-map-by ppr:$((1*${NCPUS})):node \
-oversubscribe -use-hwthread-cpus \
-x PYTHONPATH=${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi4.1.5:${HOME}/scratch/workdir/hoomd/hoomd-benchmarks \
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
cd ${HOME}/run

nodes=1 walltime=00:00:300 \
warmup_steps=40000 benchmark_steps=80000 repeat=1 N=200000 \
bash -c \
'qsub -V \
-l walltime=${walltime},ncpus=$((48*nodes)),mem=$((48*nodes*1))gb \
-N hoomd.nodes${nodes}.WS${warmup_steps}.BS${benchmark_steps} \
hoomd.sh'
```

# Read the results

The performance results of HOOMD-blue are measured in “time steps per second”. The higher the value, the better.

```bash
$ grep "time steps per second" ${HOME}/run/hoomd*.N200000.* |sort  --version-sort
/home/551/pz7344/run/hoomd.nodes1.WS40000.BS80000.N200000.o126652098:.. 414.4660591257386 time steps per second
/home/551/pz7344/run/hoomd.nodes2.WS40000.BS80000.N200000.o126652165:.. 988.4693811106713 time steps per second
/home/551/pz7344/run/hoomd.nodes4.WS40000.BS80000.N200000.o126652113:.. 1877.763554501254 time steps per second
/home/551/pz7344/run/hoomd.nodes8.WS40000.BS80000.N200000.o126652114:.. 3158.200458957586 time steps per second
/home/551/pz7344/run/hoomd.nodes16.WS40000.BS80000.N200000.o126652172:.. 4502.474588174126 time steps per second
/home/551/pz7344/run/hoomd.nodes16.WS100000.BS160000.N200000.o126652132:.. 4406.744257681727 time steps per second
/home/551/pz7344/run/hoomd.nodes32.WS40000.BS80000.N200000.o126652173:.. 5863.37070963423 time steps per second
/home/551/pz7344/run/hoomd.nodes32.WS100000.BS160000.N200000.o126652137:.. 5847.372539795664 time steps per second

```
