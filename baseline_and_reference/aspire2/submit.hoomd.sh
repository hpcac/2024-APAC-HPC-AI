cd ${HOME}/run

nodes=2 walltime=00:00:300 \
warmup_steps=40000 benchmark_steps=80000 repeat=1 N=200000 \
bash -c \
'qsub -V \
-l walltime=${walltime},select=${nodes}:ncpus=$((128*1)):mem=$((128*2))gb \
-N hoomd.nodes${nodes}.WS${warmup_steps}.BS${benchmark_steps}.N${N} \
hoomd.sh'
#warmup_steps=100000 benchmark_steps=160000 repeat=1 N=200000 \
