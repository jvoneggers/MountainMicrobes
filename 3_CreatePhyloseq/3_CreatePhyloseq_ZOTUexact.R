## 8. Create Phyloseq
require(phyloseq)
require(tidyverse)

setwd("/Users/jordanscheibe/Library/CloudStorage/OneDrive-UniversityofWyoming/LakeSedDNA/Data/MountainMicrobes/4_DataAnalysis")
### a. read in metadata tables
metadata<-read.csv(list.files(path="../3_CreatePhyloseq/",pattern = "*_metadata.csv", full.names = TRUE), header=T)
rownames(metadata)<-metadata$sample_id

### b. read in V7 files
rarefied_esv_table <- read.csv("../2_DataCleaning/ZOTU/2024-06-26_ZOTUexact_ESV_tab_10K_reads_normalized.csv", row.names=1, header=T)
taxonomy <- read.csv("../2_DataCleaning/ZOTU/2024-06-26_ZOTUexact_tax_tab_notnorm.csv", row.names=1, header=T)

### c. Put into Phyloseq
#put in "Unassigned" in blanks in taxa tab
tax_tab<-as.data.frame(taxonomy)
tax_tab[is.na(tax_tab)==TRUE]<-"Unassigned"
tax_tab <-as.matrix(tax_tab)

#covert taxa table to phyloseq sub-object
tax_tab <- tax_table(tax_tab)
rm(taxonomy)

# subset metadata data frame by the samples in 'rarefied_esv_table' and convert metadata into a phyloseq object
metadata <- metadata %>% filter(rownames(.) %in% names(rarefied_esv_table))
samp_dat <- sample_data(metadata)

#convert ESV table into a phyloseq object
esv_tab_norm <- otu_table(rarefied_esv_table, taxa_are_rows = T)
rm(rarefied_esv_table)

# make phyloseq objects
ps <- phyloseq(esv_tab_norm, samp_dat, tax_tab)

#remove phyloseq sub-objects (not metadata because we want that separately)
rm(esv_tab_norm)
rm(tax_tab)
rm(samp_dat)

#transform sample data
#ps_tr <- transform_sample_counts(ps, function(x) x / sum(x))


variation<-"ZOTUexact"