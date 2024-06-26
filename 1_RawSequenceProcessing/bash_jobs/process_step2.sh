#!/bin/bash
#SBATCH --job-name process_step2
#SBATCH --mem=100GB
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=32
#SBATCH --account=microbiome
#SBATCH --output=process_step2_%A.out


module load miniconda3/23.11.0
conda activate vsearch

echo "cutadapt version:"
cutadapt --version
vsearch --version


echo "Set usearch_global (ZOTU/OTU) table ids"
ids=(97 99)

echo "Open working directory with files for step 2 (working with concatenated files)"
cd /gscratch/jvonegge/MountainMicrobes/process/step2 || exit

echo "############## Dereplicate ##############"

vsearch -fastx_uniques seqs_samples.fa -fastaout unique_seqs.fa -sizeout -relabel Uniq_ || exit


echo "*************** Cluster denoise sequences ***************"
vsearch --cluster_unoise unique_seqs.fa --centroids ZOTU.fa \
        --minsize 8 --relabel ZOTU_ --sizein --sizeout || exit


echo "*************** Remove chimeras region DENOVO ***************"
vsearch --uchime_denovo ZOTU.fa --nonchimeras ZOTU_no_chimeras_denovo.fa \
        --sizein --sizeout --relabel ZOTU_ \
        || exit
    

for i in "${ids[@]}"
do
echo "*************** Make OTU tables ID: 0.$i ***************"
vsearch --usearch_global seqs_samples.fa \
        --db ZOTU_no_chimeras_denovo.fa \
        --otutabout ZOTU_table_${i} \
        --id 0.${i} --threads 32 || exit
        
sed -i 's/^#OTU ID/OTUID/' ZOTU_table_${i}
done


echo "*************** Make ESV table ***************"
vsearch --search_exact seqs_samples.fa \
        --db ZOTU_no_chimeras_denovo.fa \
        --otutabout ZOTU_table_exact \
        --notrunclabels --threads 32 || exit



echo "############## Cluster classic ##############"


echo "*************** Remove singletons region ***************"
vsearch --sortbysize unique_seqs.fa \
        --output unique_seqs_no_singletons.fa \
        --minsize 2 --relabel OTU- \
        --sizein --sizeout || exit

ids=(97 99)
for i in "${ids[@]}"
do
echo "############## Cluster classic, remove chimeras, make OTU tables, ID: $i ##############"

echo "*************** Cluster classic sequences ID: 0.$i ***************"
vsearch --cluster_fast unique_seqs_no_singletons.fa \
        --centroids OTU_${i}_centroid.fa \
        --clusterout_sort --relabel OTU-${i}_ --id 0.${i} \
        --threads 32 --sizein --sizeout || exit

echo "*************** Remove chimeras region DE NOVO ID: 0.$i ***************"
vsearch --uchime_denovo OTU_${i}_centroid.fa --nonchimeras OTU_${i}_no_chimeras_denovo.fa \
        --sizein --sizeout --relabel OTU-${i}_ \
        || exit

echo "*************** Make OTU tables ID: 0.$i  ***************"
vsearch --usearch_global seqs_samples.fa \
        --db OTU_${i}_no_chimeras_denovo.fa \
        --otutabout OTU_table_${i} --id 0.${i} \
        --notrunclabels --threads 32 || exit
        
sed -i 's/^#OTU ID/OTUID/' OTU_table_${i}
done


conda deactivate

echo "############## Assign taxonomy ##############"
conda activate dada2_env

cd /gscratch/jvonegge/MountainMicrobes/process/step2 || exit

cp /gscratch/jvonegge/MountainMicrobes/bash_jobs/assignTaxonomy_dada2.R /gscratch/jvonegge/MountainMicrobes/process/step2

echo "srun Rscript assignTaxonomy_dada2.R"
srun Rscript assignTaxonomy_dada2.R

conda deactivate
date
