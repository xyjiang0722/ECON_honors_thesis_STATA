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

#loop that submits jobs
while [ ${count} -le 1000 ]
do    
	sbatch --wrap="stata-se -b do /nas/longleaf/home/xiaoyanj/ondemand/data/sys/myjobs/projects/default/1/run.do ${count} ${seed}"
	count=`expr $count + 1`
done
