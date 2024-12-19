## SSTP vs XLOC dictionary

# Load necessary libraries
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("GenomicRanges")
BiocManager::install("rtracklayer")

library(GenomicRanges)
library(rtracklayer)

# Define file paths for the two GFF3 files
gff_file1 <- "sster_liftoff_WBPS18.gff3"  # Replace with the first GFF3 file
gff_file2 <- "strongyloides_stercoralis.PRJNA930454.WBPS19.annotations.gff3"  # Replace with the second GFF3 file
output_file <- "SSTP_XLOC_overlapping_genes.txt"  # Output file for overlapping gene IDs

# Load GFF3 files as GRanges objects
gr1 <- import(gff_file1, format = "gff3")
gr2 <- import(gff_file2, format = "gff3")

# Filter for genes only (feature type "gene")
genes1 <- gr1[gr1$type == "gene"]
genes2 <- gr2[gr2$type == "mRNA"]

# Find overlaps between the two sets of genes
overlaps <- findOverlaps(genes1, genes2)

# Filter overlaps to ensure they are on the same strand
same_strand <- strand(genes1[queryHits(overlaps)]) == strand(genes2[subjectHits(overlaps)])
filtered_overlaps <- overlaps[same_strand]

# Extract overlapping gene IDs
gene_ids1 <- mcols(genes1[queryHits(filtered_overlaps)])$ID
transcript_ids2 <- mcols(genes2[subjectHits(filtered_overlaps)])$ID
gene_ids2 <- mcols(genes2[subjectHits(filtered_overlaps)])$Parent

# Clean gene names by removing "gene:" from start of string
gene_ids1 <- sub("^gene:", "", gene_ids1)
gene_ids2 <- sub("^gene:", "", gene_ids2)
transcript_ids2 <- sub("^transcript:", "", transcript_ids2)

# Combine gene IDs into a data frame
overlapping_genes <- data.frame(
  SSTP_GeneID = gene_ids1,
  XLOC_GeneID = gene_ids2@unlistData,
  XLOC_TranscriptID = transcript_ids2
  
)

# Get location information for the genes based on the XLOC genome
annotations <- getBM(attributes=c('wbps_transcript_id',
                                  'chromosome_name'),
                     # grab the annotations from WormBase ParaSite
                     mart = useMart(biomart="parasite_mart", 
                                    dataset = "wbps_gene", 
                                    host="https://parasite.wormbase.org",
                                    port = 443),
                     filters = c('species_id_1010'),
                     useCache = T,
                     value = 'ststerprjna930454') %>%
  as_tibble(.name_repair = "unique") %>%
  dplyr::rename(XLOC_TranscriptID = 'wbps_transcript_id',
                Chromosome = 'chromosome_name')

overlapping_genes<- left_join(overlapping_genes, annotations, join_by(XLOC_TranscriptID))

# Write the overlapping gene IDs to a text file
write.table(overlapping_genes, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)