require(dada2)
require(Biostrings)
require(stringr)

sessionInfo()

fasta <- readDNAStringSet("ZOTU/ZOTU_no_chimeras_denovo.fa")

tax_table_80 <- assignTaxonomy(fasta, "/project/seddna/jvonegge/WY_lake_microbes/16S/reference_database/silva_nr99_v138.1_wSpecies_train_set.fa.gz", multithread = 32, minBoot=80)
write.csv(tax_table_80,"ZOTU/ZOTU_taxonomy_80_DADA2.csv")


fasta <- readDNAStringSet("OTU/OTU_97_no_chimeras_denovo.fa")

tax_table_80 <- assignTaxonomy(fasta, "/project/seddna/jvonegge/WY_lake_microbes/16S/reference_database/silva_nr99_v138.1_wSpecies_train_set.fa.gz", multithread = 32, minBoot=80)
write.csv(tax_table_80,"OTU/OTU_97_taxonomy_80_DADA2.csv")


fasta <- readDNAStringSet("OTU/OTU_99_no_chimeras_denovo.fa")

tax_table_80 <- assignTaxonomy(fasta, "/project/seddna/jvonegge/WY_lake_microbes/16S/reference_database/silva_nr99_v138.1_wSpecies_train_set.fa.gz", multithread = 32, minBoot=80)
write.csv(tax_table_80,"OTU/OTU_99_taxonomy_80_DADA2.csv")

