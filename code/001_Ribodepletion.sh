#!/bin/tcsh
#SBATCH --job-name=ribodetectorCinzia # Job name
#SBATCH --mail-type=FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J ribo
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH -N 1
#SBATCH --output=log_files/ribodetectorCinzia.log
#SBATCH -p cpu_medium
#SBATCH --cpus-per-task 4
#SBATCH --threads-per-core 1

##Ribodetection
	source code/custom-tcshrc
	module load python/cpu/3.10.6
		ribodetector_cpu -t 4  \
		-i out/processed/Trimmed/${ARG1} \
		-l 75 \
  		-e rrna \
  		-o out/processed/Ribo_ex/${ARG1}
