#!/bin/bash
#SBATCH --job-name=Trimming_of_reads	     # Job name
#SBATCH --partition=batch		             # Partition (queue) name
#SBATCH --ntasks=1			                 # Single task job
#SBATCH --cpus-per-task=6		             # Number of cores per task 
#SBATCH --mem=120gb			                 # Total memory for job
#SBATCH --output=output/log.%j			     # Location of standard output and error log files 

# Created by Fiifi Agyabeng-Dadzie
--------------------------
STEP 1: TRIMMING OF READS
--------------------------

# Load Trimmomatic
ml Trimmomatic/0.39-Java-13

# Define directories
raw_reads="path/to/raw_reads_dir"
paired="path/to/trimmed_paired_dir"
unpaired="path/to/trimmed_unpaired_dir"

# Create output directories if they don't exist
mkdir -p $paired $unpaired

# Loop through all forward read files
for filepath in $raw_reads/*.1.fq.gz
do
    # Extract base name
    base=$(basename $filepath .1.fq.gz)

    # Define reverse read file
    reverse_filepath="${raw_reads}/${base}.2.fq.gz"

    # Log processing info
    echo "Trimming sample: $base"

    # Run Trimmomatic
    java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 6 -phred33 \
        $filepath \
        $reverse_filepath \
        $paired/Trim_${base}_1_paired.fq.gz \
        $unpaired/Trim_${base}_1_unpaired.fq.gz \
        $paired/Trim_${base}_2_paired.fq.gz \
        $unpaired/Trim_${base}_2_unpaired.fq.gz \
        ILLUMINACLIP:/apps/eb/Trimmomatic/0.39-Java-13/adapters/NexteraPE-PE.fa:2:30:10:2:TRUE \
        SLIDINGWINDOW:5:20 MINLEN:50
done

echo "Trimming completed for all samples."


# --------------------------------------
# STEP 2: CHECK QUALITY OF TRIMMED READS
# --------------------------------------

for filepath in "$paired"/*.gz
do
    base=$(basename "$filepath")

    # Run seqkit stats and append results to the stats file
    seqkit stats -a "$filepath" >> "$paired/stats_trimmed_reads.txt"
done