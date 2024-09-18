#!/bin/bash
#SBATCH --job-name=STARCinzia # Job name
#SBATCH --mail-type=END,FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J RNAseq_STAR
#SBATCH --mem=5G
#SBATCH --time=48:00:00
#SBATCH -N 1
#SBATCH --output=log_files/STARCinzia.log
#SBATCH -p cpu_medium
#SBATCH --cpus-per-task 6
#SBATCH --threads-per-core 1


#Setting core variables:
        cd data/Fastq
        all_files=(ls *fastq.gz)
        cd ../../
        len=$((${#all_files[@]}-1))
        for ((i=1;i<= ${len};i++))
        do
	fastqfiles[${i}]=${all_files[${i}]%%_*}
        done
	sorted_uniqued_ids=($(echo "${fastqfiles[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

#There will be different tasks:

###Create output directory
        if test -d ./out/processed; then
                echo "Directory exists"
        else
            	mkdir ./out/processed
                mkdir ./out/processed/STAR
        fi

###Setting flags for each task

###Adapter trimming
##make wrapper script
	if test ! -d ./out/processed/Trimmed; then
		mkdir ./out/processed/Trimmed
		array1=()
		array2=()
		for ((i=0; i<${len}; i++)); do
    			array1+=("./code/001_Trimming.sh")
    			array2+=("sbatch --export=ARG1=")
		done
		paste -d '' <(printf "%s\n" "${array2[@]}") <(printf '"%s"\n' "${all_files[@]:1}") <(printf " %s\n" "${array1[@]}") > code/tmp
		./code/scripts-submit-jobs ./code/tmp 8
		#trim_job_ids=($(./code/scripts-submit-jobs ./code/tmp 8 | awk '{print $NF}'))
	fi

###Ribodepletion
##make wrapper script
	if test ! -d ./out/processed/Ribo_ex; then
		mkdir ./out/processed/Ribo_ex
		array1=()
		array2=()
		for ((i=0; i<${len}; i++)); do
			array1+=("./code/001_Ribodepletion.sh")
				array2+=("sbatch --export=ARG1=")
		done
		paste -d '' <(printf "%s\n" "${array2[@]}") <(printf '"%s"\n' "${all_files[@]:1}") <(printf " %s\n" "${array1[@]}") > code/tmp
		./code/scripts-submit-jobs ./code/tmp 4
	fi

###Alignment
##Generate STAR genome indexes
        if test ! -d ./data/Genome/STAR_index; then
                mkdir ./data/Genome/STAR_index
		./001_STAR_genome.sh
        fi

##make wrapper script
	n=$((${#sorted_uniqued_ids[@]}))
	array1=()
	array2=()
	trim_job_ids+=(${ribo_job_ids[@]})
	for ((i=0; i<${n}; i++)); do
  			array2+=("sbatch --export=ARG1=")
    		array1+=("./code/001_STAR.sh")
	done
	paste -d '' <(printf "%s\n" "${array2[@]}") <(printf '"%s"\n' "${sorted_uniqued_ids[@]}") <(printf " %s\n" "${array1[@]}") > code/tmp
	./code/scripts-submit-jobs ./code/tmp 4

###Featurecounts
	./code/003_featurecounts.sh

###Generating expression sets
	module unload r
	module load r/4.3.2
	Rscript 004_expressionset_build.R

###End
	if compgen -G "slurm*" > /dev/null; then
	rm slurm*
	fi
