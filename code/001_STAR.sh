#!/bin/tcsh
#SBATCH --job-name=STARalignCinzia # Job name
#SBATCH --mail-type=FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J RNAseq_STAR
#SBATCH --mem=40G
#SBATCH --time=24:00:00
#SBATCH -N 1
#SBATCH --output=log_files/STARalignCinzia.log
#SBATCH -p cpu_medium
#SBATCH -c 16
#SBATCH --threads-per-core 1
##Load modules
source code/custom-tcshrc
module load star/2.7.11b 

	if (! -d ./out/processed/STAR/${ARG1}) then
        	 mkdir ./out/processed/STAR/${ARG1}
#Get file list

#		set file_list=`ls -m data/Fastq/${ARG1}* | tr -d ' ' | tr -d '\n'`        	#For untrimmed reads
#		set file_list=`ls -m out/processed/Trimmed/${ARG1}* | tr -d ' ' | tr -d '\n'`		#For trimmed reads
		set file_list = `ls -m out/processed/Ribo_ex/${ARG1}* | tr -d ' ' | tr -d '\n'`		#For trimmed and ribodepleted reads

#STAR alignment
		STAR --genomeDir  data/Genome/STAR_index \
		--runThreadN 10 \
		--readFilesIn ${file_list} \
		--readFilesCommand zcat\
		--outFileNamePrefix out/processed/STAR/${ARG1}/ \
		--outSAMtype BAM Unsorted \
		--limitBAMsortRAM 10000000000 \
		--outSAMunmapped Within \
		--outFilterMultimapNmax 10\
		--outFilterMultimapScoreRange 3 \
		--outFilterMismatchNmax 999 \
		--outFilterMismatchNoverLmax 0.04 \
		--outSAMstrandField intronMotif    #For subsequent use of StringTie

#Sorted and indexed bam
		samtools sort -o out/processed/STAR/${ARG1}/Aligned.sortedByCoord.out.bam -m 80G out/processed/STAR/${ARG1}/Aligned.out.bam
		samtools index out/processed/STAR/${ARG1}/Aligned.sortedByCoord.out.bam

		set dir = `pwd`
        	if (! -d ./out/QC) then
        	        mkdir ./out/QC
		endif
        	if (! -d ./out/QC/STAR) then
        	        mkdir ./out/QC/STAR
		endif
		ln -sn ${dir}/${i}/Log.final.out out/QC/STAR/`basename $i`Log.final.out
	endif

