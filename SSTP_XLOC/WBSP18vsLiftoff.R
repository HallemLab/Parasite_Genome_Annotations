## SSTP WBPS18 vs Liftoff Gene dictionary

pacman::p_load("tidyverse","stringr","magrittr","biomaRt", "seqinr")

# Function to extract gene names from a GFF3 file
extract_gene_names <- function(gff3_file, attribute_name = "ID") {
  # Read the GFF3 file
  gff3_data <- read.delim(gff3_file, comment.char = "#", header = FALSE, sep = "\t")
  
  # Filter rows with 'gene' as the feature type
  genes <- gff3_data %>% filter(V3 == "gene")
  
  # Extract gene names from the attribute column (column 9)
  gene_names <- genes$V9 %>%
    stringr::str_extract(paste0(attribute_name, "=[^;]+")) %>% # Extract the attribute
    stringr::str_replace(paste0(attribute_name, "=gene:"), "")    # Remove the attribute prefix
  
  return(unique(gene_names))
}

# Compare two GFF3 files
compare_gff3_files <- function(file1, file2, attribute_name = "ID", output_file = "unique_genes.txt") {
  # Extract gene names from both files
  genes_file1 <- extract_gene_names(file1, attribute_name)
  genes_file2 <- extract_gene_names(file2, attribute_name)
  
  # Find genes unique to each file
  unique_to_file1 <- setdiff(genes_file1, genes_file2)
  unique_to_file2 <- setdiff(genes_file2, genes_file1)
  
  # Combine results into a data frame
  result <- tibble(
    geneID = c(unique_to_file1, unique_to_file2),
    source = c(rep("Liftoff", length(unique_to_file1)), rep("WBPS18", length(unique_to_file2)))
  ) %>%
    group_by(geneID)
  
}

# Define file paths for the two GFF3 files
gff_file1 <- "sster_liftoff_WBPS18.gff3"
gff_file2 <- "../GFF3s/strongyloides_stercoralis.PRJEB528.community.annotations.gff3"
gene_list <-compare_gff3_files(gff3_file1, gff3_file2, attribute_name = "ID", output_file = "unique_genes.txt")

sequences <- getBM(attributes=c('wbps_gene_id',
                                  'peptide',
                                'description'),
                     # grab the annotations from WormBase ParaSite
                     mart = useMart(biomart="parasite_mart", 
                                    dataset = "wbps_gene", 
                                    host="https://release-18.parasite.wormbase.org", #Using the archived version of biomart because the XLOC gene ids are not useful.
                                    port = 443),
                     filters = list('species_id_1010'="ststerprjeb528", 'wbps_gene_id'=gene_list$geneID),
                     useCache = T) %>%
  dplyr::rename(geneID = "wbps_gene_id") %>%
  group_by(geneID) %>%
  add_column(length = nchar(sequences$peptide)) %>%
  relocate(description, length, peptide, .after = geneID) %>%
  arrange(desc(length))

# Remove source code to shorten the description
sequences$description <- sequences$description %>%
  str_replace_all(string = ., 
                  pattern = "  \\[Source:.*\\]", 
                  replacement = "")

# Remove `*` from peptide
sequences$peptide <- sequences$peptide %>%
  str_replace_all(string = ., 
                  pattern = "\\*", 
                  replacement = "")


write.fasta(sequences = as.list(sequences$peptide), names = sequences$geneID, as.string = F, file.out = "Missing_SSTP_sequences.fasta")

output.path <-"./"
output.name <- "Missing_SSTP_sequences.xlsx"

write.xlsx(sequences,
     file = file.path(output.path,
                      output.name))

