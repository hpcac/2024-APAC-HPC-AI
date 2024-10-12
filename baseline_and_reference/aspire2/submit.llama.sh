cd ${HOME}/run

nodes=2 walltime=7201 \
global_batch_size=128 micro_batch_size=32 max_steps=20 \
bash -c \
'qsub -V \
-l walltime=${walltime},select=${nodes}:ngpus=4 \
-N llama.nodes${nodes}.GBS${global_batch_size}.MBS${micro_batch_size} \
llama.sh'
