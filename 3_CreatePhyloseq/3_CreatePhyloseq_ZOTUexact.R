## 8. Create Phyloseq
require(phyloseq)
require(tidyverse)


#Add date and name below if modifying or rerunning this script
####### 07.09.2024 Modified by Ioana Stefanescu

# JV comment - if you put the files in the same folder it can shorthand to them with the ".." and then we can all run the 3_CreatePhyloseq.R script (it wasn't working on my computer anymore because you put in the full path that connected to your desktop). I'll comment this out so that you can still see it but change it back so that we can all load the data this way! It should work the same for you as well.

# 
# setwd("/Users/ioana/Desktop/MountainMicrobes/4_DataAnalysis")
# 
# ### a. read in metadata tables
# metadata<-read.csv("/Users/ioana/Desktop/MountainMicrobes/6_MetadataAnalysis/2024-07-08_mountain_microbes_sample_metadata.csv",  header=T)
# metadata<- metadata[!metadata$sample_type == "MC_71", ] # remove the one unidentified soil sample Ioana_G12
# rownames(metadata)<-metadata$sample_id



### a. read in metadata tables
metadata<-read.csv("../6_MetadataAnalysis/2024-07-08_mountain_microbes_sample_metadata.csv",  header=T)
metadata<- metadata[!metadata$sample_type == "MC_71", ] # remove the one unidentified soil sample Ioana_G12
rownames(metadata)<-metadata$sample_id


### b. read in V7 files
rarefied_esv_table <- read.csv("../2_DataCleaning/ZOTU/2024-06-26_ZOTUexact_ESV_tab_10K_reads_normalized.csv", row.names=1, header=T)
taxonomy <- read.csv("../2_DataCleaning/ZOTU/2024-06-26_ZOTUexact_tax_tab_notnorm.csv", row.names=1, header=T)


#Check which samples are in the ESV file but not in the Metadata
diffs = setdiff(names(rarefied_esv_table), metadata$sample_id) 
#print(diffs)

#Check which samples are in the Metadata file but not in the ESV
diffs = setdiff(metadata$sample_id,names(rarefied_esv_table)) 
#print(diffs)

rm(diffs) # JV - removed this so it doesn't show up in the final output


### c. Put into Phyloseq
#put in "Unassigned" in blanks in taxa tab
tax_tab<-as.data.frame(taxonomy)
tax_tab[is.na(tax_tab)==TRUE]<-"Unassigned"
tax_tab <-as.matrix(tax_tab)

#covert taxa table to phyloseq sub-object
tax_tab <- tax_table(tax_tab)
rm(taxonomy)

# subset metadata data frame by the samples in 'rarefied_esv_table' and convert metadata into a phyloseq object

#check sample number in esv vs metadata
length(rarefied_esv_table)
# [1] 616
length(metadata$sample_id)
# [1] 653
# difference of 37 samples 

metadata <- metadata %>% filter(rownames(.) %in% names(rarefied_esv_table))
length(metadata$sample_id)
# [1] 609
samp_dat <- sample_data(metadata)


#write.csv(metadata, "/Users/ioana/Desktop/MountainMicrobes/6_MetadataAnalysis/Metadata_for_keptsamples_ZOTUexact.csv")

#convert ESV table into a phyloseq object
esv_tab_norm <- otu_table(rarefied_esv_table, taxa_are_rows = T)
rm(rarefied_esv_table)


# make phyloseq objects
ps <- phyloseq(esv_tab_norm, samp_dat, tax_tab)

#transform sample data
ps_tr <- transform_sample_counts(ps, function(x) x / sum(x))
variation<-"ZOTUexact"


#remove phyloseq sub-objects (not metadata because we want that separately)
rm(esv_tab_norm)
rm(tax_tab)
rm(samp_dat)
