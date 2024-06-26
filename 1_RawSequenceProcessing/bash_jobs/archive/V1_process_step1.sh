#!/bin/bash
#SBATCH --job-name step1_16S
#SBATCH --mem=100GB
#SBATCH --time=5:00:00
#SBATCH --cpus-per-task=32
#SBATCH --account=microbiome
#SBATCH --output=V1_process_step1_%A.out


module load miniconda3/23.11.0
conda activate vsearch

echo "cutadapt version:"
cutadapt --version
vsearch --version

echo "First version (V1): main options are error rate for cutadapt is 0.25 and the maxdiffpct for merging is 0.25 (this resuls in sometimes a low number of reads passing through to the next step - more for Calder samples than MAWC and SNOTEL). Merging selected 20 bp overlap to allow for longer reads but there was not an issue of the overlap being too short here. I did not truncate and join reads that did not merge."

echo "Make new directory for output files"
version=$(echo "V1")
cd /gscratch/jvonegge/MountainMicrobes/
mkdir ${version}_process/

echo "Set names"
cd /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files
samples=$(ls | awk -F '.soil|.Calder' '{print $1}' | uniq)

echo "Remove primers"
for s in $samples;
do
cutadapt -g ^GTGYCAGCMGCCGCGGTAA -o ../${version}_process/${s}_R1_primers_removed.fastq \
        -G ^GGACTACHVGGGTWTCTAAT -p ../${version}_process/${s}_R2_primers_removed.fastq \
        ${s}*.R1.fq ${s}*.R2.fq \
        --error-rate 0.25 --discard-untrimmed --cores=32 || exit
done

echo "Move to new directory"
cd /gscratch/jvonegge/MountainMicrobes/${version}_process || exit

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
        --fastq_maxdiffpct 0.25 --fastq_minovlen 20 --fastq_minmergelen 200 \
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


echo "Run next job (step 2)"
cd /gscratch/jvonegge/MountainMicrobes/bash_jobs
sbatch ${version}_process_step2.sh 

echo "deactivate conda environment"
conda deactivate

