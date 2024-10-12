cd ${HOME}/run

nodes=2 walltime=00:00:600 \
global_batch_size=128 micro_batch_size=32 max_steps=20 \
bash -c \
'qsub -V \
-l walltime=${walltime},ncpus=$((${nodes}*4*12)),mem=$((${nodes}*4*32))gb,ngpus=$((${nodes}*4)) \
-N llama.nodes${nodes}.GBS${global_batch_size}.MBS${micro_batch_size} \
llama.sh'
