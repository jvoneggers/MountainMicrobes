#!/bin/bash
#SBATCH --job-name process_step2
#SBATCH --mem=100GB
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=32
#SBATCH --account=microbiome
#SBATCH --output=V1_process_step2_%A.out


module load miniconda3/23.11.0
conda activate vsearch

echo "cutadapt version:"
cutadapt --version
vsearch --version


echo "Set variable names"
version=$(echo "V1")
ids=(97 99)

echo "Open working directory with files for step 2 (working with concatenated files)"
cd /gscratch/jvonegge/MountainMicrobes/${version}_process/step2 || exit

echo "############## Dereplicate ##############"

vsearch -fastx_uniques seqs_samples.fa -fastaout unique_seqs.fa -sizeout -relabel Uniq_ || exit


echo "*************** Cluster denoise sequences ***************"
vsearch --cluster_unoise unique_seqs.fa --centroids ZOTU.fa \
        --minsize 8 --relabel ZOTU_ --sizein --sizeout || exit


echo "*************** Remove chimeras region DENOVO ***************"
vsearch --uchime_denovo ZOTU.fa --nonchimeras ZOTU_no_chimeras_ref_no_singletons.fa \
        --sizein --sizeout --relabel ZOTU_ \
        || exit
    
  
for i in "${ids[@]}"
do
echo "*************** Make OTU tables ID: 0.$i ***************"
vsearch --usearch_global seqs_samples.fa \
        --db ZOTU_no_chimeras_ref_no_singletons.fa \
        --otutabout ZOTU_table_${i} \
        --id 0.${i} --threads 32 || exit
done


conda deactivate

echo "############## Assign taxonomy ##############"
conda activate dada2_env

cd /gscratch/jvonegge/MountainMicrobes/${version}_process/step2 || exit

cp /gscratch/jvonegge/MountainMicrobes/bash_jobs/${version}_assignTaxonomy_dada2.R /gscratch/jvonegge/MountainMicrobes/${version}_process/step2

echo "srun Rscript assignTaxonomy_dada2.R"
srun Rscript ${version}_assignTaxonomy_dada2.R


echo "Check ambiguities (N bases) after filtering step"

echo "Number of N bases after filtering:"
grep 'N' /gscratch/jvonegge/MountainMicrobes/${version}_process/step2/seqs_samples.fa | grep -v '^>' | wc -l 

echo "############## Count track step 1 ##############"

cho "Count track for raw sequence DNA processing for Step 1"

echo "Vstarting reads:"
cat /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files/*.fastq | grep -c "@rna16S"

echo "Total number of samples (duplicated):"
ls -1 /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files | wc -l 

echo "Primers removed:"
cd /gscratch/jvonegge/MountainMicrobes/${version}_process/

echo "Reads after primers removed:"
cat *primers_removed_headers.fastq | grep -c "@rna16S"

echo "Reads after pairs merged:"
cat *_merged.fastq | echo $((`wc -l`/4))


cd /gscratch/jvonegge/MountainMicrobes/${version}_process/step2

echo "Total sequences after filtering:"
grep -c ">" seqs_samples.fa

conda deactivate


