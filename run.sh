#!/bin/bash

#initialize counter
count=1

#compile rand
gcc /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/tstrand.c -o rand

#load stata
module load stata

#generate seeds for random number generator from seed 12345, generate 20,000 seeds
seeds=`./rand 12345 20000`

#arrange seeds in a 20,000x1 table
arr=($seeds)

exec < /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/shape_comb.csv|| exit 1
read header

#loop that submits jobs
while IFS=, read p_0 p_1 alpha_2 mu0_0 mu0_1 beta_2 mu1_0 mu1_1 gamma_2; do
	#[ ${count} -le 10 ]
	#count is the job ID
	#arr[$count] is the seed
    echo p_0="$p_0"
    echo p_1="$p_1"
    echo alpha_2="$alpha_2"
    echo mu0_0="$mu0_0"
    echo mu0_1="$mu0_1"
    echo beta_2="$beta_2"
    echo mu1_0="$mu1_0"
    echo mu1_1="$mu1_1"
    echo gamma_2="$gamma_2"

	sbatch --wrap="stata-se -b do /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/run.do ${count} ${arr[$count]} ${p_0} ${p_1} ${alpha_2} ${mu0_0} ${mu0_1} ${beta_2} ${mu1_0} ${mu1_1} ${gamma_2}"
	count=`expr $count + 1`
done
