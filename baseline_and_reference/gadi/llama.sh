#!/bin/bash
#PBS -j oe
#PBS -l walltime=00:00:200
#PBS -m abe
#PBS -M 393958790@qq.com
#PBS -P xs75
#PBS -q gpuvolta

date
module purge
module load pbs openmpi/4.1.5

env
cat $PBS_NODEFILE
#hosts=$(sort -u ${PBS_NODEFILE} | paste -sd ',')
#-host ${hosts} -np 8 \

cmd="mpirun \
-wdir ${HOME}/scratch/workdir/llama \
-output-filename ${HOME}/run/output/${PBS_JOBNAME}.${PBS_JOBID} \
-map-by ppr:4:node -oversubscribe \
-report-bindings \
-x NCCL_DEBUG=INFO \
-x NCCL_NET_GDR_LEVEL=6 \
${HOME}/scratch/workdir/llama/litgpt.py312/bin/litgpt \
finetune_full \
${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf \
--out_dir ${HOME}/scratch/workdir/llama/out/finetune/full \
--data JSON --data.json_path ${HOME}/scratch/workdir/llama/dataset/alpaca1024 \
--config ${HOME}/scratch/workdir/llama/full.yaml \
--eval.final_validation=false \
--train.epochs=1 \
--devices=4 --num_nodes=2 \
--train.max_steps=${max_steps} \
--train.global_batch_size=${global_batch_size} \
--train.micro_batch_size=${micro_batch_size}"

echo ${cmd}

exec ${cmd}
date
