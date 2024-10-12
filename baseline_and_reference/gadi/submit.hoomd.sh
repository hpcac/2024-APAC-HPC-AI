cd ${HOME}/run

nodes=2 walltime=00:00:300 \
warmup_steps=40000 benchmark_steps=80000 repeat=1 N=200000 \
bash -c \
'qsub -V \
-l walltime=${walltime},ncpus=$((48*nodes)),mem=$((48*nodes*1))gb \
-N hoomd.nodes${nodes}.WS${warmup_steps}.BS${benchmark_steps}.N${N} \
hoomd.sh'
#warmup_steps=100000 benchmark_steps=160000 repeat=1 N=200000 \
