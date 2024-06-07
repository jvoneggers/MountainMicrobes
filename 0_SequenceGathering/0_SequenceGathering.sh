# Jordan Von Eggers
# 4 June 2024
# Here I am 

# Log in 
ssh jvonegge@beartooth.arcc.uwyo.edu


# Copy over Ioana's samples
cd /project/microbiome/data_queue/seq/ReRun4/rawdata/sample_fastq/16S/SNOTEL
cp * /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files

# count number of samples 
cd /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files
ls -1 | wc -l
# 384

# Copy over Dulcinea's samples

cd /project/microbiome/data_queue/seq/ReRun3/rawdata/16Ssample_fastq/16S/MAWC
ls -1 | wc -l
#1472
cp * /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files


# Copy over Jordan's samples
cd /project/microbiome/data/seq/psomagen_17sep20_novaseq2/
ls -1 | wc -l
# 2612
cp * /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files


cd /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files
ls -1 | wc -l
# 4468
# 1472 + 384 + 2612
