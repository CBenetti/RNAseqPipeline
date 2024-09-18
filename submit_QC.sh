#!/bin/bash
#SBATCH --job-name=QCCinzia # Job name
#SBATCH --mail-type=END,FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J RNAseq_QC
#SBATCH --mem=4G
#SBATCH --time=6:00:00
#SBATCH -N 1
#SBATCH --output=log_files/QCCinzia.log
#SBATCH -p cpu_medium


	for param in code/QC_params/use/*;
	do
	./${param}
	done
