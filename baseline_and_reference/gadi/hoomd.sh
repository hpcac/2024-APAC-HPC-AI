#!/bin/bash
#PBS -j oe
#PBS -M 393958790@qq.com
#PBS -m abe
#PBS -P xs75
#PBS -l walltime=00:00:60
##PBS -l other=hyperthread

#-report-bindings \
#-map-by ppr:48:node \
#-map-by ppr:96:node \

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
-N 200000 --repeat ${repeat} \
--warmup_steps ${warmup_steps} --benchmark_steps ${benchmark_steps}"

echo ${cmd}

exec ${cmd}
date
