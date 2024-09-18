#!/bin/tcsh
#SBATCH --job-name=TrimmomaticCinzia # Job name
#SBATCH --mail-type=FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J Trimming
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=log_files/TrimmomaticCinzia.log
#SBATCH -N 1
#SBATCH -p cpu_medium
source code/custom-tcshrc
##Adapter removal
		module load miniconda3/4.6.14
		conda activate trimmomatic_env
		trimmomatic SE -phred33  data/Fastq/${ARG1} out/processed/Trimmed/${ARG1} ILLUMINACLIP:TruSeq3-SE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
		conda deactivate
		module unload miniconda3/4.6.14
