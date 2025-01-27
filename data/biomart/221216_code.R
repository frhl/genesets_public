library(biomaRt)
library(data.table)
ensembl <- useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl", GRCh = 38)
transcripts <- getBM(attributes=c('ensembl_gene_id','ensembl_transcript_id','hgnc_symbol','chromosome_name','start_position','end_position', 'transcript_start', 'transcript_end'), 
      mart = ensembl, filters = "chromosome_name", values = as.character(1:22))
transcripts$length <- (transcripts$transcript_end - transcripts$transcript_start)
fwrite(transcripts, "~/Projects/09_genesets/genesets/data/biomart/221216_enstid_ensgid_lengths.txt.gz")

