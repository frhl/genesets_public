

library(data.table)

normalize_names <- function(names_vector) {
  names_vector <- gsub(" [ ]+", " ", names_vector)
  names_vector <- gsub(" / ", "/", names_vector)
  names_vector <- gsub("([a-z])(\\()", "\\1 \\2", names_vector)
  names_vector <- gsub(",", "", names_vector)
  names_vector <- gsub("-", " ", names_vector)
  names_vector <- gsub("[\\(,\\)]", "", names_vector)
  names_vector <- gsub("'", "", names_vector)
  names_vector <- gsub(" ", "_", names_vector)
  names_vector <- gsub("\\/", "_or_", names_vector)
  return(tolower(names_vector))
}

#
cutoffs <- c(0.90,0.95,0.99, 0.999)
for (cutoff in cutoffs){
  
  tstat <- fread("~/Projects/09_genesets/genesets/data/gtex/GTEx.tstat.tsv")
  cats <- fread("~/Projects/09_genesets/genesets/data/gtex/GTEX.tstat.categories.genoppi.csv")
  colnames(cats) <- tolower(colnames(cats))

  # subset to specific
  tstat_only <- tstat[,-1]
  tissue_specific <- lapply(tstat_only, function(x) tstat$ENSGID[x>quantile(x, probs=cutoff)])
  tissue_specific <- stack(tissue_specific)
  tissue_specific$geneset <- normalize_names(tissue_specific$ind)
  
  # normalise categories andn combine
  cats$geneset <- normalize_names(cats$tissue)
  stopifnot(all(tissue_specific$geneset %in% cats$geneset))
  merged <- merge(tissue_specific, cats, all.x=TRUE)
  
  # clean up 
  merged$ind <- NULL
  merged$tissue.genoppi <- NULL
  
  print(paste("rows:", nrow(merged)))
  
  # write out
  out_prefix <- paste0("exported/gtex.tissue_specific", cutoff)
  fwrite(merged, paste0(out_prefix, ".txt.gz"))
  fwrite(data.table(unique(merged$geneset)), paste0(out_prefix, ".genesets"), col.names=FALSE)
  
  
}


