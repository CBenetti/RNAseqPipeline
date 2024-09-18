#!/bin/tcsh
#SBATCH --job-name=STARCinzia # Job name
#SBATCH --mail-type=END,FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J RNAseq_STAR
#SBATCH --mem=50G
#SBATCH --time=24:00:00
#SBATCH -N 1
#SBATCH --output=log_files/STARCinzia.log
#SBATCH -p cpu_medium
#SBATCH --cpus-per-task 6
#SBATCH --threads-per-core 1

source code/custom-tcshrc
module load star/2.7.11b
               
        STAR --runThreadN 4 --runMode genomeGenerate --genomeDir data/Genome/STAR_index \
        --sjdbGTFfile data/Genome/hg38.ensGene.gtf \
        --genomeFastaFiles data/Genome/hg38_genome.fa
