setwd("~/Projects/27_genesets_public/genesets_public/")

library(biomaRt)
library(data.table)
library(jsonlite)

# get genemap
ensembl <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl", GRCh = 38)
result <- getBM(attributes=c('ensembl_gene_id','hgnc_symbol'), mart = ensembl)
result <- result[result$hgnc_symbol!="",]
gene_map <- result$ensembl_gene_id
names(gene_map) <- result$hgnc_symbol

# Read the JSON file

json_files_to_process <- list.files("json/", full.names=TRUE)

for (json_path in json_files_to_process){
    
  json_data <- fromJSON(json_path)
  json_basename <- tools::file_path_sans_ext(basename(json_path))
  outfile <- file.path("exported",paste0(json_basename,".txt.gz"))
  outpathways <- file.path("exported",paste0(json_basename,".pathways"))
  
  # Initialize an empty list to store pathway names and gene names
  pathway_list <- list()
  
  # Iterate over each pathway in the JSON data
  for (pathway_name in names(json_data)) {
    pathway <- json_data[[pathway_name]]
    
    # Extract gene names
    gene_symbols <- pathway$geneSymbols
    
    # Extract other relevant information
    external_details_url <- pathway$externalDetailsURL
    msigdb_url <- pathway$msigdbURL
    
    # Store pathway name, gene names, and other relevant information in a list
    pathway_info <- list(
      pathway = pathway_name,
      hgnc_symbol = gene_symbols
    )
    
  
    # Append the pathway information to the list
    pathway_list <- c(pathway_list, list(pathway_info))
  }
  
  # Convert the list to a data.table
  pathway_data <- rbindlist(pathway_list, fill = TRUE)
  pathway_data$gene_id <- gene_map[pathway_data$hgnc_symbol]
  
  n_pathways <- length(unique(pathway_data$pathway))
  print(paste("Pathways:", n_pathways, "-- writing to", outfile))
  fwrite(pathway_data, outfile)
  fwrite(data.table(unique(pathway_data$pathway)), outpathways, col.names=FALSE)
  
}


