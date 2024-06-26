#!/bin/bash
#SBATCH --job-name step1_16S
#SBATCH --mem=100GB
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=32
#SBATCH --account=microbiome
#SBATCH --output=process_step1_%A.out


module load miniconda3/23.11.0
conda activate vsearch

echo "cutadapt version:"
cutadapt --version
vsearch --version

echo "Main options are error rate for cutadapt is 0.25 and the maxdiff for merging is 20 (increasing from default of 10 because there should be plenty of overlap with 40 basepairs). When I compared on the test files between 20 bp and 40 bp minovlen there was no change and only a few reads had overlaps too short. No difference for test samples for using 150 bp min merge length verses 200 on the test files. I left this at 150 because others using this region use a much shorter mininum merged length (UWyo Micro Project uses 60 which I think is too short since the averages I found for this V4 region online are 291, 300+, and 254 base pairs). The main loss of samples was when I went from maxdiffs 20 to 10, which makes sense because we have a lot of overlap, so left at 20 maxdiffs. I didn't increase maxdiffs because 95-98% of the reads merged in the test files. I did not truncate and join reads that did not merge."

echo "Make new directory for output files"
cd /gscratch/jvonegge/MountainMicrobes/
mkdir process/

echo "Set names"
cd /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files
samples=$(ls | awk -F '.soil|.Calder' '{print $1}' | uniq)

echo "Remove primers"
for s in $samples;
do
cutadapt -g ^GTGYCAGCMGCCGCGGTAA -o ../process/${s}_R1_primers_removed.fastq \
        -G ^GGACTACHVGGGTWTCTAAT -p ../process/${s}_R2_primers_removed.fastq \
        ${s}*.R1.fq ${s}*.R2.fq \
        --error-rate 0.25 --discard-untrimmed --cores=32 || exit
done

echo "Move to new directory"
cd /gscratch/jvonegge/MountainMicrobes/process || exit

echo "Change headers"
for s in $samples;
do
sed 's/\s/_/g' ${s}_R1_primers_removed.fastq | sed -e 's/^@16/@rna16/' - | sed -e 's/-/_/g' > ${s}_R1_primers_removed_headers.fastq
sed 's/\s/_/g' ${s}_R2_primers_removed.fastq | sed -e 's/^@16/@rna16/' - | sed -e 's/-/_/g' > ${s}_R2_primers_removed_headers.fastq
done

echo "Merge pairs"

for s in $samples;
do
vsearch --fastq_mergepairs ${s}_R1_primers_removed_headers.fastq \
        --reverse ${s}_R2_primers_removed_headers.fastq \
        --fastqout ${s}_merged.fastq \
        --fastq_maxdiffs 20 --fastq_minovlen 40 --fastq_minmergelen 150 \
        --fastq_allowmergestagger --threads 32 \
        --sample $s \
        --fastqout_notmerged_fwd ${s}_notmerged_R1.fastq \
        --fastqout_notmerged_rev ${s}_notmerged_R2.fastq || exit
done

echo "Filter and concatenate all sequences"
for s in $samples;
do
vsearch -fastq_filter ${s}_merged.fastq -fastq_maxee 1 -fastaout ${s}_filtered.fa || exit
cat ${s}_filtered.fa >> seqs_samples.fa 
done


echo "Put concatenated sequences into a step 2 folder"
mkdir step2
mv seqs_samples.fa step2

echo "Put step 1 files into a step 1 folder"
mkdir step1
mv *.fa step1
mv *.fastq step1

echo "Run next job (step 2)"
cd /gscratch/jvonegge/MountainMicrobes/bash_jobs
sbatch process_step2.sh 

echo "deactivate conda environment"
conda deactivate

