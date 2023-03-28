## Author: Mehaa Prabakar. RVersion:2022.12.0+353. Packages: jsonlite version: 1.8.4, curl version: 5.0.0, igraph version: 1.4.1

library(curl)
library(jsonlite)
library(igraph)

# URL for STRING API query
query <- "SCN1A%0dDravet%20syndrome"
url <- paste0("https://string-db.org/api/json/get_string_ids?identifiers=", query, "&species=9606")

# API request
handle <- curl(url)
results <- readLines(handle)
close(handle)

json <- fromJSON(results)

# get protein IDs for SCN1A gene
scn1a_protein_ids <- json$stringId[json$preferredName == "SCN1A"]
print(scn1a_protein_ids)

# get protein IDs for Dravet syndrome
dravet_protein_ids <- json$stringId[json$preferredName == "Dravet syndrome"]
print(dravet_protein_ids)

# protein nodes
proteins <- c("SCN1A", scn1a_protein_ids)
diseases<- c("Dravet syndrome", dravet_protein_ids)

# edges
edges <- matrix(c("SCN1A", scn1a_protein_ids), ncol = 2, byrow = TRUE)

# create graph 
g <- graph_from_edgelist(edges, directed = TRUE)

# Set node names
V(g)$label <- proteins

# node colors
V(g)$color <- ifelse(V(g)$label == "SCN1A", "red", "blue")

# edge colors
E(g)$color <- "black"
  
# plot network
plot(g, edge.curved = 0.2, edge.arrow.size = 0.5, layout = layout_nicely)



