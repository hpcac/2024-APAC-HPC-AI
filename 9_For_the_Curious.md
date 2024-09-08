[toc]

# For the Curious

# Create HOOMD-blue initial configurations

You don’t need to perform the following operations yourself. Please use the existing initial configuration files available on the shared storage that we have prepared for you.

## Run from command line

The following commands:

1. Create a initial condition files with 500 particles at directory `initial_configuration_cache` under HOOMD-blue work directory
2. Run no simulation
3. The command line is even workable on the login nodes

```bash
cd ${HOME}/scratch/workdir/hoomd

module purge
module load openmpi/4.1.5

time mpirun \
-wdir ${HOME}/scratch/workdir/hoomd \
-map-by ppr:2:node \
-x PYTHONPATH=${HOME}/scratch/workdir/hoomd/build/hoomd-openmpi4.1.5:${HOME}/scratch/workdir/hoomd/hoomd-benchmarks \
${HOME}/scratch/workdir/hoomd/hoomd.py312/bin/python \
-m hoomd_benchmarks.md_pair_wca \
--device CPU -v \
-N 500 \
--warmup_steps 0 --benchmark_steps 0
```

# Create LitGPT Dataset and Model Files

You don’t need to perform the following operations yourself. Please use the existing dataset and model files available on the shared storage that we have prepared for you.

## Dataset - Alpaca subset

### Create a subset of Alpaca in JSON format

The following commands

1. Download `Alpaca2k` dataset from HuggingFace
2. As a example, extract the first 100 lines of `Alpaca2k` and save them in JSON format as alpaca1024

```bash
time ${HOME}/scratch/workdir/llama/litgpt.py312/bin/huggingface-cli download \
--repo-type dataset mhenrichsen/alpaca_2k_test \
--local-dir ${HOME}/scratch/workdir/llama/trial/mhenrichsen/alpaca_2k_test
# real	0m6.222s

time ${HOME}/scratch/workdir/llama/litgpt.py312/bin/python -c "import json; import os;
from datasets import load_dataset;
os.chdir(os.path.join(os.environ['HOME'], 'scratch/workdir/llama/trial'));
os.makedirs('alpaca1024', exist_ok=True)
train_data = load_dataset('mhenrichsen/alpaca_2k_test', split='train[:1024]');
val_data = load_dataset('mhenrichsen/alpaca_2k_test', split='train[-1:]');
with open('alpaca1024/train.json', 'w', encoding='utf-8') as f: json.dump(train_data.to_list(), f, ensure_ascii=False, indent=1);
with open('alpaca1024/val.json', 'w', encoding='utf-8') as f: json.dump(val_data.to_list(), f, ensure_ascii=False, indent=1);"
# real	0m2.772s
```

### A CPU toy model fine-tuning trial with the subset of Alpaca

```bash
time OMP_NUM_THREADS=4 \
${HOME}/scratch/workdir/llama/litgpt.py312/bin/litgpt \
finetune \
${HOME}/scratch/workdir/llama/trial/checkpoints/EleutherAI/pythia-70m \
--out_dir ${HOME}/scratch/workdir/llama/trial/out/finetune/lora \
--data JSON --data.json_path ${HOME}/scratch/workdir/llama/trial/alpaca100 \
--eval.final_validation=false \
--train.epochs=1 \
--train.max_steps=1000
```

## Model - LitGPT Llama2-7B

### Download Meta Llama2-7B model files 

The following commands

1. Download `meta-llama` model files to the model directory
2. Print the directory structure of the downloaded files

```
mkdir -p ${HOME}/scratch/workdir/llama/model/meta
cd ${HOME}/scratch/workdir/llama/model/meta

time git -C ${HOME}/scratch/workdir/llama clone https://github.com/meta-llama/llama
time bash ${HOME}/scratch/workdir/llama/llama/download.sh
# Follow the instructions in ${HOME}/scratch/workdir/llama/llama/README.md
# real	29m53.219s

tree -h ${HOME}/scratch/workdir/llama/model/meta
#/root/scratch/workdir/llama/model/meta
#├── [ 6.9K]  LICENSE
#├── [   89]  llama-2-7b
#│   ├── [  100]  checklist.chk
#│   ├── [  13G]  consolidated.00.pth
#│   └── [  102]  params.json
#├── [   50]  tokenizer_checklist.chk
#├── [ 488K]  tokenizer.model
#└── [ 4.7K]  USE_POLICY.md
#1 directory, 7 files
```

### Generate HuggingFace model files

The following commands

1. Add downloaded `tokenizer.model`  to `llama-2-7b` directory
2. Fixes a Python `argparse` boolean bug in HuggingFace transformers library
3. Convert the `meta-llama` model into HuggingFace model files

```bash
ln -s ${HOME}/scratch/workdir/llama/model/meta/tokenizer.model ${HOME}/scratch/workdir/llama/model/meta/llama-2-7b/

sed -i 's/default=True/default=False/g' \
${HOME}/scratch/workdir/llama/litgpt.py312/lib/python3.12/site-packages/transformers/models/llama/convert_llama_weights_to_hf.py

time ${HOME}/scratch/workdir/llama/litgpt.py312/bin/python \
${HOME}/scratch/workdir/llama/litgpt.py312/lib/python3.12/site-packages/transformers/models/llama/convert_llama_weights_to_hf.py \
--input_dir ${HOME}/scratch/workdir/llama/model/meta/llama-2-7b \
--output_dir ${HOME}/scratch/workdir/llama/model/huggingface/meta-llama/Llama-2-7b-hf \
--llama_version 2 \
--model_size=7B
# real	4m25.221s
```

### Generate LitGPT model files

The following commands

1. Convert HuggingFace modle files into LitGPT model files
2. Move LitGPT model files into a separate directory and added `tokenizer` files

```bash
time ${HOME}/scratch/workdir/llama/litgpt.py312/bin/litgpt \
convert_to_litgpt ${HOME}/scratch/workdir/llama/model/huggingface/meta-llama/Llama-2-7b-hf
# real	1m38.831s

mkdir -p ${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf
mv ${HOME}/scratch/workdir/llama/model/huggingface/meta-llama/Llama-2-7b-hf/{lit_model.pth,model_config.yaml} ${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf

ln -s ${HOME}/scratch/workdir/llama/model/huggingface/meta-llama/Llama-2-7b-hf/{tokenizer.json,tokenizer_config.json} ${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf
```

# Some LitGPT Trials

## Get started with a CPU trial

The following commands

1. Create a workspace directory for trial runs
2. Execute a dummy run to download the smallest model and dataset

```bash
mkdir -p ${HOME}/scratch/workdir/llama/trial
cd ${HOME}/scratch/workdir/llama/trial

time OMP_NUM_THREADS=1 \
CUDA_VISIBLE_DEVICES="" \
${HOME}/scratch/workdir/llama/litgpt.py312/bin/litgpt \
finetune \
EleutherAI/pythia-70m \
--data Alpaca2k \
--train.max_steps=1 \
--eval.final_validation=false \
--data.val_split_fraction=0.00001
# real	1m29.023s
```

## Validate distributed training with a small MPI trial

Create a bash script named `nodes2.litgpt.openmpi4.sh` with the following contents

1. Defined PBS command directives to submit the job to the GPU queue 
2. Load Environment modules to configure the running shell, after purging all loaded modules
3. Print environment variables of the shell for this script, and the node list for this job
4. Launch a distributed training with OpenMPI
   - Define a runtime work directory for the job, allowing the use of relative path such as `EleutherAI/pythia-70m`
   - Request 4 ranks(GPU processes) per node from the 2 allocated nodes
   - Enable NCCL verbose output
   - Run a `pythia-70m` fine-tuning task and exit immediately after 1 step

```bash
#!/bin/bash
#PBS -j oe
#PBS -l walltime=00:00:60
#PBS -q gpuvolta
#PBS -m abe
#PBS -M 393958790@qq.com
#PBS -P xs75

module purge
module load pbs openmpi/4.1.5

env
cat $PBS_NODEFILE

mpirun \
-wdir ${HOME}/scratch/workdir/llama/trial \
-map-by ppr:4:node \
-x NCCL_DEBUG=INFO \
${HOME}/scratch/workdir/llama/litgpt.py312/bin/litgpt \
finetune-full \
EleutherAI/pythia-70m \
--train.max_steps=1 \
--devices=4 --num_nodes=2
```

## A GPU Llama2-7B fine-tuning trial with the subset of Alpaca

```bash
#!/bin/bash
#PBS -j oe
#PBS -l walltime=00:00:60
#PBS -q gpuvolta
#PBS -m abe
#PBS -M 393958790@qq.com
#PBS -P xs75

module purge
module load pbs openmpi/4.1.5 hcoll/4.8.3223 ucx/1.15.0 ucc/1.2.0

env
cat $PBS_NODEFILE

mpirun \
-wdir ${HOME}/scratch/workdir/llama/trial \
-map-by ppr:4:node \
-x NCCL_DEBUG=INFO \
${HOME}/scratch/workdir/llama/litgpt.py312/bin/litgpt \
finetune-full \
${HOME}/scratch/workdir/llama/model/litgpt/meta-llama/Llama-2-7b-hf \
--out_dir ${HOME}/scratch/workdir/llama/trial/out/finetune/lora \
--data JSON --data.json_path ${HOME}/scratch/workdir/llama/trial/alpaca1024 \
--eval.final_validation=false \
--train.epochs=1 \
--train.max_steps=1 \
--devices=4 --num_nodes=2
```

