# RNAseq pipeline
This pipeline is developed to work on HPC environments
It is designed for processing single-end stranded sequencing data, from one or multiple lanes. It allows multi-sample processing  trough the Slurm workload manager.

* ### System requirements
##### 1. HPC environment
The following system files must be present in your environment, to make sure that the HPC cluster architecture is compatible
```
/etc/profile.d/modules.csh
```
This file is necessary to determine that cluster environment are set correcly when executing the workload manager

````
/bin/bash
/bin/tcsh
````

While bash shell is usually readily available, tcsh is needed as well. It is possible to install and configured in most unix based system and distributions:

##### Debian-Based Distributions
Debian and Ubuntu
Package Manager: apt
Install Command: 
````
sudo apt-get install tcsh
````


##### Red Hat-Based Distributions
CentOS
Package Manager: yum or dnf
Install Command:
````
sudo yum install tcsh (for older versions)
sudo dnf install tcsh (for CentOS 8 and later)
````

Fedora
Package Manager: dnf
Install Command: 
````
sudo dnf install tcsh
````

##### SUSE-Based Distributions
openSUSE
Package Manager: zypper
Install Command: 
````
sudo zypper install tcsh
````

##### 2. Available modules and packages
The following modules and versions are required:
1. r/4.3.2. 
This R version must be equipped with the following packages:
    * dplyr
    * ggplot2
    * Biobase
    * GenomicFeatures
    * ensembldb
    * AnnotationHub
2. r/3.6.1
3. python/cpu/3.6.5
4. python/cpu/3.10.6
5. miniconda3/4.6.14
The following environment must be installed:
    * Picard:
    It contains Picard conda installation, as per instructed [here](https://anaconda.org/bioconda/picard)
    * trimmomatic_env
    It contains Trimmomatic conda installation, as per instructed [here](https://bioinformaticschool.com/mastering-trimmomatic-installation/)
6. ucscutils/398
7. bedops/2.4.41
8. parallel/20231222
9. fastqc/0.11.7
10. subread/1.6.3
11. star/2.7.11b
12. samtools/1.9
13. bedtools/2.27.1
14. gtools/3.0.0
15. java/1.8
16. gsl/2.5

* ### Usage
##### 1. Installation
Create a new empty project directory. The name will be usewd to name the resulting dataset, therefore it should be explicative and not start with a number
```
mkdir project_dir
cd project_dir
```
Clone this git repository inside the directory and extract the files as to obtain the architecture.
```
git clone repo temp_repo
mv temp_repo/* ./
rm -r temp_repo
```

##### 2. Input format
To run, the pipeline requires
* fastq input data
    symbolic links must be created to the data directory as follows:
    ```
    ln -ns your/fastq_dir data/Fastq
    ```
* Genome data
    This directory must contain:
   1. Genome .fa file
   2. compatible gtf format annotations
  
  They can be downloaded de novo or linked from other projects
* metadata.txt file
This file contains the metadata for dataset generation and subsequent analysis
Its structure should be the following:
    - One row for each sample
    - One column for each annotation
    - A way to reconduct a sample name to fastq names (before _R1_L004.fastq). It can be one field or the combination of many, and it showld be set as rownames, by modifying line 21-22 of file in code/004_expressionset_build.R


##### 3. Run
From the project directory:
1. Source alignment file
```
sbatch submit_align.sh
```
This will run, in order Read trimming, Ribodepletion of trimmed reads, STAR genome index build, Alignment with STAR of Trimmed and Ribodepleted reads, featureCounts and Expressionset build to obtain the normalized count matrix.
2. Select the features on which to perform QC
On the QC_param directory, move all the desired QCs in the use directory
```
ls QC_params/*
mv 002_QC* QC_params/use/
```
Submit the script
```
sbatch submit_QC.sh
```

##### 4. Output
In the output directory, you will find:
- processed folder
It contains processed fastqs (Trimmed, Ribodepleted) and STAR alignment results

- QC folder
It contains QC from the varoius steps

- count_matrix folder
It contains the raw matrix obtained with featureCounts and the processed and normalized R expressionset, containing COUNTS, CPM and FPKM values
