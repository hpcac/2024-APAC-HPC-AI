#!/bin/bash
#PBS -P 50000022
#PBS -l walltime=00:00:60
#PBS -j oe
#PBS -M 393958790@qq.com
#PBS -m abe
##-map-by ppr:$((2*${NCPUS})):node \
##-bind-to hwthread -use-hwthread-cpus \
##-report-bindings \

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
