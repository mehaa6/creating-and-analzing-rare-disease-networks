## Author: Mehaa Prabakar. RVersion:2022.12.0+353. Packages: jsonlite version: 1.8.4, Rcurl version: 5.0.0, SPARQL version: 1.16.1, 
# BiomaRt version 2.54.1: magritter version: 2.0.3

library(SPARQL)
library(RCurl)
library(jsonlite)
library(biomaRt)
library(magrittr)

mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")

# SPARQL query for finding genes associated with disease
endpoint <- "http://rdf.disgenet.org/sparql/"
query1 <- "SELECT DISTINCT ?gene ?geneName
WHERE {
	?gda sio:SIO_000628 ?gene, ?disease .
	?gene rdf:type ncit:C16612 ;
		dcterms:title ?geneName .
	?disease rdf:type ncit:C7057 ;
		dcterms:title 'Infantile Severe Myoclonic Epilepsy'@en .
}"

# SPARQL query to retrieve genes associated with disease
results1 <- SPARQL(endpoint, query1)$results
gene_symbols <- results1$geneName

# gene symbols to Ensembl IDs
gene_ids <- getBM(attributes = c("ensembl_gene_id"), 
                  filters = "hgnc_symbol", 
                  values = gene_symbols, 
                  mart = mart)$ensembl_gene_id

# function to retrieve ppis for a single gene ID
get_ppis_single <- function(gene_id) {
  url <- paste0("https://string-db.org/api/tsv/network?identifiers=",
                gene_id,
                "&species=9606&add_nodes=0")
  # get data from API and convert to data frame
  data <- getURL(url) %>% strsplit("\t") %>% data.frame(stringsAsFactors = FALSE)
  colnames(data) <- c("protein1", "protein2", "neighborhood", "neighborhood_transferred", "fusion", 
                      "cooccurence", "coexpression", "experimental", "database", "textmining", 
                      "combined_score")

  return(data)
}

# get_ppis_single function for each gene ID
ppis <- lapply(gene_ids, get_ppis_single)
ppis <- do.call(rbind, ppis)

# print names
print(gene_ids)
print(ppis)
