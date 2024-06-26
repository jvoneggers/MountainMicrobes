#!/bin/bash
#SBATCH --job-name 16S_taxonomy
#SBATCH --mem=100GB
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=32
#SBATCH --account=microbiome
#SBATCH --output=process_step3_assignTaxonomy_%A.out


module load miniconda3/23.11.0

echo "############## Assign taxonomy ##############"
conda activate dada2_env

cd /gscratch/jvonegge/MountainMicrobes/process/step2 || exit

cp /gscratch/jvonegge/MountainMicrobes/bash_jobs/assignTaxonomy_dada2.R /gscratch/jvonegge/MountainMicrobes/process/step2

echo "srun Rscript assignTaxonomy_dada2.R"
srun Rscript assignTaxonomy_dada2.R

conda deactivate
date