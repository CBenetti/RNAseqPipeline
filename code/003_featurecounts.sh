#!/bin/bash
#SBATCH --job-name=featureCCinzia # Job name
#SBATCH --mail-type=END,FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=cinzia.benetti@edu.unito.it # Where to send mail
#SBATCH -J RNAseq_featureC
#SBATCH --mem=80G
#SBATCH --time=24:00:00
#SBATCH -N 1
#SBATCH --output=log_files/featureCCinzia.log
#SBATCH -p cpu_medium
#SBATCH -c 6
module load subread/1.6.3

        if test ! -d ./out/count_matrix
        then
            	mkdir ./out/count_matrix
        fi

	##raw counts on transcripts
	featureCounts -T 6 -a data/Genome/hg38.ensGene.gtf -F GTF -t transcript -g gene_id -s 1 -o out/count_matrix/tableCounts_t out/processed/STAR/*/Aligned.sortedByCoord.out.bam
	featureCounts -T 6 -a data/Genome/hg38.ensGene.gtf -F GTF -t transcript -g gene_id -s 2 -o out/count_matrix/tableCounts_t_rev out/processed/STAR/*/Aligned.sortedByCoord.out.bam
        if test ! -d ./out/QC/featureCounts
        then
            	mkdir ./out/QC/featureCounts
        fi
	##raw counts on exons
	featureCounts -T 6 -a data/Genome/hg38.ensGene.gtf -F GTF -t exon -g gene_id -s 1 -o out/count_matrix/tableCounts_e out/processed/STAR/*/Aligned.sortedByCoord.out.bam
	featureCounts -T 6 -a data/Genome/hg38.ensGene.gtf -F GTF -t exon -g gene_id -s 2 -o out/count_matrix/tableCounts_e_rev out/processed/STAR/*/Aligned.sortedByCoord.out.bam
	mv out/count_matrix/tableCounts*summary ./out/QC/featureCounts/
