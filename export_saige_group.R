
null_omit <- function(lst) {
  lst[!vapply(lst, is.null, logical(1))]
}

library(data.table)
files <- list.files("~/Projects/27_genesets_public/genesets_public/exported/", full.names=TRUE, pattern="txt.gz$")

for (f in files){
  write(paste("reading", f, "and writing saige group files.."))
  file_basename <- gsub(".txt.gz$","",(basename(f)))
  outfile <- file.path("exported",paste0(file_basename,".saige_group.txt.gz"))

  # export geneset and gene id
  stopifnot(c("geneset","gene_id") %in% colnames(d))
  all_genesets <- unique(d$geneset)
  out <- lapply(all_genesets, function(gs){
    genes <- d$gene_id[d$geneset %in% gs]
    annotations <- rep("geneset", length(genes))
    row1 <- paste(c(gs,'var', genes), collapse = " ")
    row2 <- paste(c(gs, 'anno', annotations), collapse = " ")
    return(paste0(c(row1, row2), collapse = '\n'))
  })
  out <- null_omit(out)
  write(paste("Writing to", outfile), stdout())
  writeLines(paste(out, collapse = '\n'), outfile)
}



