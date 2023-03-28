## Author: Mehaa Prabakar. RVersion:2022.12.0+353. Packages: jsonlite version: 1.8.4, curl version: 5.0.0, igraph version: 1.4.1

library(curl)
library(jsonlite)
library(igraph)

# URL for STRING API query
query <- "SCN1A%0dDravet%20syndrome"
url <- paste0("https://string-db.org/api/json/get_string_ids?identifiers=", query, "&species=9606")

# API request to STRING
handle <- curl(url)
results <- readLines(handle)
close(handle)

json <- fromJSON(results)

#protein ID for SCN1A gene
scn1a_protein_id <- json$stringId[json$preferredName == "SCN1A"]

#protein ID for Dravet syndrome
dravet_protein_ids <- json$stringId[json$preferredName == "Dravet syndrome"]

#protein nodes
proteins <- c("SCN1A", scn1a_protein_id, dravet_protein_ids)
protein_names <- c("SCN1A", "SCN1A protein", "Dravet protein")
protein_colors <- c("red", "blue", "blue")

#edges
edges <- matrix(c("SCN1A", scn1a_protein_id, "SCN1A protein", dravet_protein_ids), ncol = 2, byrow = TRUE)

# Create graph 
g <- graph_from_edgelist(edges, directed = TRUE)

# node names and colors
V(g)$label <- protein_names
V(g)$color <- protein_colors

# edge colors
E(g)$color <- "black"
  
# DrugBank API query
db_url <- "https://api.drugbank.com/v1/targets?search="

# API request to DrugBank
drug_targets <- list()
for (protein_id in proteins) {
  drugbank_url <- paste0(db_url, protein_id)
  handle <- curl(drugbank_url)
  results <- readLines(handle)
  close(handle)
  json <- fromJSON(results)
  if (length(json$targets) > 0) {
    drug_targets[[protein_id]] <- json$targets[[1]]$drugs
  } else {
    drug_targets[[protein_id]] <- NULL
  }
}

#  drug target nodes
drug_nodes <- c()
drug_names <- c()
for (protein_id in names(drug_targets)) {
  if (!is.null(drug_targets[[protein_id]])) {
    drug_nodes <- c(drug_nodes, paste0(protein_id, "-", drug_targets[[protein_id]]$drugbank_id))
    drug_names <- c(drug_names, drug_targets[[protein_id]]$name)
  }
}

# add drug target nodes to graph
g <- add.vertices(g, length(drug_nodes), label = drug_names, color = "green")
V(g)$label <- c(protein_names, drug_names)

# Add drug target edges to graph
drug_edges <- matrix(ncol = 2, nrow = 0)
for (protein_id in names(drug_targets)) {
  if (!is.null(drug_targets[[protein_id]])) {
    for (i in 1:length(drug_targets[[protein_id]]$drugbank_id)) {
      drug_edges <- rbind(drug_edges, c(paste0(protein_id, "-", drug_targets[[protein_id]]$drugbank_id[i]), protein_id))
    }
  }
}
g <- add.edges(g, drug_edges)

# plot network
plot(g, edge.curved = 0.2, edge.arrow.size = 0.5, layout = layout_nicely)
