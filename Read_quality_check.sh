#!/bin/bash
#SBATCH --job-name=read_quality_check	     # Job name
#SBATCH --partition=batch		             # Partition (queue) name
#SBATCH --ntasks=1			                 # Single task job
#SBATCH --cpus-per-task=6		             # Number of cores per task 
#SBATCH --mem=120gb			                 # Total memory for job
#SBATCH --output=path/to/output/log.%j		 # Location of standard output and error log files 

# Created by Fiifi Agyabeng-Dadzie
# --------------------------------------
# STEP 1: CHECK THE REACOUNT AND QUALITY
# --------------------------------------

# Load the SeqKit module (version 2.9.0)
ml SeqKit/2.9.0

# Define the path to the directory containing raw FASTQ files
raw_reads="path/to/raw_reads_dir"

# Loop through all FASTQ files (.fq.gz) in the specified directory
for fq_files in $raw_reads/*.fq.gz
do
    # Extract the base name of the FASTQ file (remove the .fq.gz extension)
    Base_name=$(basename $fq_files .fq.gz)
    
    # Generate statistics for each FASTQ file using seqkit
    # The '-a' flag provides more detailed (advanced) statistics
    # Append the output to 'raw_reads_stats.txt' within the raw_reads directory
    seqkit stats -a $fq_files >> $raw_reads/raw_reads_stats.txt
done
