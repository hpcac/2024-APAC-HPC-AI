[toc]

# Set up LitGPT Framework

## Install LitGPT

The following commands

1. Created a workspace directory for Llama2 in the scratch directory
2. Set up a Python 3 Conda environment
3. Install the pre-built LitGPT from https://pypi.org/project/litgpt 

```bash
mkdir ${HOME}/scratch/workdir/llama -p
time conda create -p ${HOME}/scratch/workdir/llama/litgpt.py312 python=3.12 -y
# real	1m49.484s
time ${HOME}/scratch/workdir/llama/litgpt.py312/bin/pip install 'litgpt[all]'
# real	4m23.324s
```

## Enable MPI Support for LitGPT Pytorch

The following commands

1. Load administrator-provided Environment modules to configure environment variables for the running shell
2. Install `mpi4py` from the shell to enable MPI Support for Python AI frameworks

```bash
#module purge
module load openmpi/4.1.5

time LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/pbs/default/lib:/lib64 \
MPI4PY_BUILD_MPICC=$OMPI_ROOT/bin/mpicc \
${HOME}/scratch/workdir/llama/litgpt.py312/bin/pip \
install --no-cache-dir mpi4py
# real	1m41.891s
```

# Prepare Dataset and LitGPT Configuration

## Get Dataset and Model files

The Llama2 module files and Alpaca dataset are available in the shared storage directory at `/scratch/public`

```bash
mkdir -p ${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf
mkdir -p ${HOME}/scratch/workdir/llama/dataset

time rsync -avSP \
/scratch/public/2024-apac-hpc-ai/llama/model/litgpt/meta-llama/Llama-2-7b-hf/ \
${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf/

time rsync -avSP \
/scratch/public/2024-apac-hpc-ai/llama/dataset/ \
${HOME}/scratch/workdir/llama/dataset/
```

## Create LitGPT fine-tuning configurations

Check the LitGPT `config_hub` files

```bash
time git -C ${HOME}/scratch/workdir/llama clone https://github.com/Lightning-AI/litgpt
grep -v -e \# -e '^\s*$' ${HOME}/scratch/workdir/llama/litgpt/config_hub/finetune/llama-2-7b/full.yaml
```

Create a `${HOME}/scratch/workdir/llama/full.yaml` config file with the following contents

```
precision: bf16-true
resume: false
train:
  save_interval: 20000
  log_interval: 1
  epochs: 1
  max_steps:
  max_seq_length: 512
eval:
  interval: 25000
  initial_validation: false
  final_validation: false
logger_name: csv
```

# Run the Distributed finetune-full Task

## Create PBS bash script

Create a script file `${HOME}/run/llama.sh` with the following contents:

```bash
#!/bin/bash
#PBS -j oe
#PBS -l walltime=00:00:200
#PBS -m abe
#PBS -M 393958790@qq.com
#PBS -P xs75
#PBS -q gpuvolta

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
```

## Submit the job script to PBS

```bash
cd ${HOME}/run

nodes=2 walltime=00:00:600 \
global_batch_size=128 micro_batch_size=32 max_steps=20 \
bash -c \
'qsub -V \
-l walltime=${walltime},ncpus=$((${nodes}*4*12)),mem=$((${nodes}*4*32))gb,ngpus=$((${nodes}*4)) \
-N llama.nodes${nodes}.GBS${global_batch_size}.MBS${micro_batch_size} \
llama.sh'
```

## Check runtime log

```bash
tail -f ${HOME}/run/output/llama.nodes2.GBS64.MBS8.{PBS_JOBNAME.PBS_JOBID}.gadi-pbs/1/rank.*/std*
```

# Read the results

The performance results of LitGPT Llama2 training are measured in “Training time”. The lower the value, the better.

```
grep "Training time: 418.99s" ${HOME}/run/llama.* -r
#llama.nodes2.GBS128.MBS32.o124452549:Training time: 422.16s
```

