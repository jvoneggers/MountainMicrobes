
echo "Check ambiguities (N bases) after filtering step"

echo "Number of N bases after filtering:"
grep 'N' /gscratch/jvonegge/MountainMicrobes/process/step2/seqs_samples.fa | grep -v '^>' | wc -l 
# 0 - no ambiguities

echo "############## Count track step 1 ##############"

cho "Count track for raw sequence DNA processing for Step 1"

echo "Vstarting reads:"
cat /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files/*.fq | grep -c "@16S"
#314806364

echo "Total number of samples (duplicated):"
ls -1 /gscratch/jvonegge/MountainMicrobes/0_raw_fastq_files | wc -l 
#4468

echo "Primers removed:"
cd /gscratch/jvonegge/MountainMicrobes/process/step1

echo "Reads after primers removed:"
cat *primers_removed_headers.fastq | grep -c "@rna16S"
# 314799630

echo "Reads after pairs merged:"
cat *_merged.fastq | echo $((`wc -l`/4))


cd /gscratch/jvonegge/MountainMicrobes/process/step2

echo "Total sequences after filtering:"
grep -c ">" seqs_samples.fa


echo "Number of ZOTUs:"
grep -c ">" ZOTU_no_chimeras_denovo.fa
#223164

echo "Number of 97% OTUs:"
grep -c ">" OTU_97_no_chimeras_denovo.fa
#118593

echo "Number of 99% OTUs:"
grep -c ">" OTU_99_no_chimeras_denovo.fa
#345986
