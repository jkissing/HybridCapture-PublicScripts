#!/bin/bash
#SBATCH --job-name=read_quality_check	     # Job name
#SBATCH --partition=batch		             # Partition (queue) name
#SBATCH --ntasks=1			                 # Single task job
#SBATCH --cpus-per-task=6		             # Number of cores per task 
#SBATCH --mem=120gb			                 # Total memory for job
#SBATCH --output=path/to/output/log.%j		 # Location of standard output and error log files 

# Created by Fiifi Agyabeng-Dadzie
# --------------------------------------
# STEP 1: ALIGN READS TO A REFERENCE GENOME
# --------------------------------------
# Define paths
in="path/to/paired_trimmed_files"
output="path/to/bam_files"
Ref="path/to/reference_sequence"

# Load necessary modules
ml BWA/0.7.17-GCCcore-11.3.0
ml SAMtools/1.16.1-GCC-11.3.0

# Index the reference genome
bwa index $Ref/reference_sequence.fna
samtools faidx $Ref/reference_sequence.fna

# Create output directory if it doesn't exist
mkdir -p $output

# Initialize the read count summary file
echo -e "Sample\tUnique_Mapped_Reads" > $output/read_count_summary.txt

# Loop to map all paired-end reads
for fq1 in $in/*_R1.fq.gz
do
    # Extract base name
    base=$(basename $fq1 _R1.fq.gz)
    fq2="$in/${base}_R2.fq.gz"

    # Mapping, BAM conversion, sorting, and marking duplicates
    bwa mem -t 6 $Ref/reference_sequence.fna $fq1 $fq2 | \
    samtools view - -O BAM | \
    samtools fixmate -m - - | \
    samtools sort -o $output/${base}_fixmate_sorted.bam && \
    samtools markdup $output/${base}_fixmate_sorted.bam $output/${base}_fixmate_sorted_marked_duplicate.bam

    # Error handling
    if [ $? -ne 0 ]; then
        echo "Error processing $base" >> error.log
        continue
    fi

    # Count unique mapped reads (exclude duplicates and unmapped reads)
    unique_mapped_reads=$(samtools view -c -F 0x400 -F 4 $output/${base}_fixmate_sorted_marked_duplicate.bam)

    # Save the read count to the summary file
    echo -e "${base}\t${unique_mapped_reads}" >> $output/read_count_summary.txt
done

# --------------------------------------
# STEP 2: INDEX BAM FILES
# --------------------------------------
# Index BAM files
for bam_file in $output/*_fixmate_sorted_marked_duplicate.bam
do
    samtools index -@ 6 $bam_file
done

echo "All samples processed, indexed, and read counts summarized."
