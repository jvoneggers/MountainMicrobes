require(dada2)
require(Biostrings)
require(stringr)

sessionInfo()

fasta <- readDNAStringSet("ZOTU_no_chimeras_ref_no_singletons.fa")

tax_table_80 <- assignTaxonomy(fasta, "/project/seddna/jvonegge/WY_lake_microbes/16S/reference_database/silva_nr99_v138.1_wSpecies_train_set.fa.gz", multithread = 32, minBoot=80)
write.csv(tax_table_80,"ZOTU_taxonomy_80_DADA2.csv")

tax_table_90 <- assignTaxonomy(fasta, "/project/seddna/jvonegge/WY_lake_microbes/16S/reference_database/silva_nr99_v138.1_wSpecies_train_set.fa.gz", multithread = 32, minBoot=90)
write.csv(tax_table_90,"ZOTU_taxonomy_90_DADA2.csv")

tax_table_95 <- assignTaxonomy(fasta, "/project/seddna/jvonegge/WY_lake_microbes/16S/reference_database/silva_nr99_v138.1_wSpecies_train_set.fa.gz", multithread = 32, minBoot=95)
write.csv(tax_table_95,"ZOTU_taxonomy_95_DADA2.csv")

